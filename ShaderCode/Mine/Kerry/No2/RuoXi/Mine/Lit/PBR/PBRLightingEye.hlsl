/*
�۾���ɣ�
sclera ��Ĥ�����۰�
Iris ��Ĥ
Pupil ͫ��
Limbus ��ĤԵ
Cornea ��Ĥ
*/
#include "PBRBRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


half2 ScaleUVsByCenter(half2 uv, float scale)
{
    float2 center = float2(0.5, 0.5);
    return (uv - center) / scale + center;
}

half2 ScaleUVFromCircle(half2 uv, float scale)
{
    float2 center = float2(0.5, 0.5);
    float2 dirFromCenter = uv - center;
    float lenFromCenter = length(dirFromCenter);
    // UV on circle at distance 0.5 from the center, in direction of original UV
    float2 uvMax = normalize(dirFromCenter) * 0.5f;
    float weight = saturate((1 - lenFromCenter * 2) * scale);
    float2 uvScaled = lerp(uvMax, float2(0.f, 0.f), weight);
    return uvScaled + center;
}

float3 RefractDirection(float internalIoR,float3 WorldNormal,float3 incidentVector)
{
    float airIoR = 1.00029;

    float n = airIoR / internalIoR;

    float facing = dot(WorldNormal, incidentVector);

    float w = n * facing;

    float k = sqrt(1+(w-n)*(w+n));

    float3 t = -normalize((w - k) * WorldNormal - n * incidentVector);
    return t;
}

void EyeRefraction_float(float2 UV,float3 NormalDir,float3 ViewDir,half IOR,
                        float IrisUVRadius,float IrisDepth,float3 EyeDirection,float3 WorldTangent,
                        out float2 IrisUV,out float IrisConcavity)
{
    IrisUV = float2(0.5,0.5);
    IrisConcavity = 1.0;
    // ģ������ͨ����Ĥ������
    float3 RefractedViewDir = RefractDirection(IOR,NormalDir,ViewDir);
    float cosAlpha = dot(ViewDir,EyeDirection);    // EyeDirection���۾���ǰ������
    cosAlpha = lerp(0.325,1,cosAlpha * cosAlpha);//������������ļн�
    RefractedViewDir = RefractedViewDir * (IrisDepth / cosAlpha);//��Ĥ���Խ������Խǿ��������������н�Խ������Խǿ��

    //����WorldTangent�����EyeDirection��ֱ��������Ҳ���Ǻ�Ĥƽ���Tangent��BiTangent����,Ҳ����UV��ƫ�Ʒ���
    float3 TangentDerive = normalize(WorldTangent - dot(WorldTangent,EyeDirection) * EyeDirection);
    float3 BiTangentDerive = normalize(cross(EyeDirection,TangentDerive));
    float RefractUVOffsetX = dot(RefractedViewDir,TangentDerive);
    float RefractUVOffsetY = dot(RefractedViewDir,BiTangentDerive);
    float2 RefractUVOffset = float2(-RefractUVOffsetX,RefractUVOffsetY);
    float2 UVRefract = UV + IrisUVRadius * RefractUVOffset;
    //UVRefract = lerp(UV,UVRefract,IrisMask);
    IrisUV = (UVRefract - float2(0.5,0.5)) / IrisUVRadius * 0.5 + float2(0.5,0.5);
    IrisConcavity = length(UVRefract - float2(0.5,0.5)) * IrisUVRadius;

}

/*
�������ԣ���2������ֱ�����
1. Sclera(�۰�)��������+���淴�䡣
2. Iris+Cornea������Ĥ�ͽ�Ĥ�����Ǵ���ͬһλ�á��������ȵ����Ĥ����Ĥ�ȽϹ⻬����������淴�䣬��ʱ�����һ����������ʣ��Ĺ��ߵ����ڲ����������䡣
*/
float3 DirectLighting_Eye(Light light, float3 diffCol, float3 specCol, float3 worldNormal, float3 irisNormal, float3 causticNormal, float3 worldPos, float a2, float irisMask,
                        Texture2D sssLut, SamplerState sssLutSampler)
{
    float3 L = light.direction;
    float3 V = GetWorldSpaceNormalizeViewDir(worldPos);
    float3 H = normalize(L + V);
    float3 N = worldNormal;
    float NoH = saturate(dot(N, H));
    float NoV = saturate(abs(dot(N, V)) + 1e-5);
    float NoL = saturate(dot(N, L));
    float VoH = saturate(dot(V, H));
    float3 fixedLightCol = light.color * light.shadowAttenuation * light.distanceAttenuation * PI;

    // ������
    // ��Ĥ
    // ��ɢ �ο�UE4���룺EyeBxDF
	float NoL_iris = saturate(dot(irisNormal, L));
	float power = lerp(12, 1, NoL_iris);
	float caustic = 0.3 + (0.8 + 0.2 * (power + 1 )) * pow(saturate(dot(causticNormal, L)), power);
	NoL_iris = NoL_iris * caustic;
    float3 irisCol = NoL_iris.xxx;                                                                   

    // ��Ĥ
    float Nol_sclera = saturate(dot(N, L));
    float2 uv_sss = float2(Nol_sclera * 0.5 + 0.5, 0.9);
    float3 sssCol = SAMPLE_TEXTURE2D(sssLut, sssLutSampler, uv_sss);

    float3 NoL_diff = lerp(sssCol, irisCol, irisMask);
    float3 diffuseLighting = Diffuse_Lambert(diffCol) * NoL_diff * fixedLightCol;

    // ��Ĥ���淴��
    float D_cornea = D_GGX_ue4(a2, NoH);
    float Vis_cornea = Vis_SmithJointApprox(a2, NoV, NoL);
    float3 F_cornea = F_Schlick_ue4(specCol, VoH) * irisMask;
    float3 specLighting_cornea = (D_cornea * Vis_cornea * F_cornea) * NoL * fixedLightCol;
    float lossEnergy = F_cornea;

    float3 lighting = diffuseLighting * (1 - lossEnergy) + specLighting_cornea;
    //lighting = caustic.xxx;
    return lighting;
}

float3 AllDirectLighting_Eye(float3 diffCol, float3 specCol, float3 worldNormal, float3 irisNormal, float3 causticNormal, float3 worldPos, float roughness, float irisMask,
                            Texture2D sssLut, SamplerState sssLutSampler)
{
    float a2 = Pow4(roughness);
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
    Light mainLight = GetMainLight(shadowCoord);

    float3 directLighting = DirectLighting_Eye(mainLight, diffCol, specCol, worldNormal, irisNormal, causticNormal, worldPos, a2, irisMask, sssLut, sssLutSampler);

    #ifdef _ADDITIONAL_LIGHTS
        uint addLightCount = GetAdditionalLightsCount();
        for(uint lightIndex = 0; lightIndex < addLightCount; ++lightIndex)
        {
            Light addLight = GetAdditionalLight(lightIndex, worldPos);
            directLighting += DirectLighting_Eye(addLight, diffCol, specCol, worldNormal, irisNormal, causticNormal, worldPos, a2, irisMask, sssLut, sssLutSampler);
        }
    #endif

    return directLighting;
}

float3 IndirectLighting_Eye(float3 diffCol, float3 specCol, float3 worldNormal, float3 worldPos, float roughness)
{
    float3 V = GetWorldSpaceNormalizeViewDir(worldPos);
    float3 N = worldNormal;
    float NoV = saturate(abs(dot(N, V))+1e-5);

    // SH
    half3 sh = SampleSH(N);
    half3 diffuseLighting = diffCol * sh;

    // LD IBL
    half3 reflectDir = reflect(-V, N);
    half3 specLD = GlossyEnvironmentReflection(reflectDir, worldPos, roughness, 1);

    // DFG
    half3 specDFG = EnvBRDFApprox(specCol, roughness, NoV);
    half3 specLighting = specLD * specDFG;

    float3 indirectLighting = diffuseLighting + specLighting;
    return indirectLighting;
}

float3 PBRLighting_Eye(float3 diffCol, float3 specCol, float3 worldNormal, float3 irisNormal, float3 causticNormal, float3 worldPos, float irisMask, Texture2D sssLut, SamplerState sssLutSampler)
{
    float roughness = lerp(0.1, 0.01, irisMask);
    float3 directLighting = AllDirectLighting_Eye(diffCol, specCol, worldNormal, irisNormal, causticNormal, worldPos, roughness, irisMask, sssLut, sssLutSampler);
    float3 indirectLighting = IndirectLighting_Eye(diffCol, specCol, worldNormal, worldPos, roughness);
    //indirectLighting = float3(0,0,0);
    return directLighting + indirectLighting;
}