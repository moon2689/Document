/*
眼睛组成：
sclera 巩膜，即眼白
Iris 虹膜
Pupil 瞳孔
Limbus 角膜缘
Cornea 角膜
*/
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "PBRBRDF.hlsl"

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
    // 模拟视线通过角膜后被折射
    float3 RefractedViewDir = RefractDirection(IOR,NormalDir,ViewDir);
    float cosAlpha = dot(ViewDir,EyeDirection);    // EyeDirection是眼睛正前方方向
    cosAlpha = lerp(0.325,1,cosAlpha * cosAlpha);//视线与眼球方向的夹角
    RefractedViewDir = RefractedViewDir * (IrisDepth / cosAlpha);//虹膜深度越大，折射越强；视线与眼球方向夹角越大，折射越强。

    //根据WorldTangent求出与EyeDirection垂直的向量，也就是虹膜平面的Tangent和BiTangent方向,也就是UV的偏移方向
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
光照特性，分2个区域分别讨论
1. Sclera(眼白)，漫反射+镜面反射。
2. Iris+Cornea，即虹膜和角膜，它们处于同一位置。光线率先到达角膜，角膜比较光滑，会产生镜面反射，此时会损耗一部分能量，剩余的光线到达内部发生漫反射。
*/
half3 BRDF_Eye(Light light, half3 diffCol, half3 specCol, float3 worldPos, half3 N, half3 irisNormal, half3 causticNormal, half a2, half irisMask)
{
    half3 L = light.direction;
    half3 V = GetWorldSpaceNormalizeViewDir(worldPos);
    half3 H = normalize(L + V);
    half NoH = saturate(dot(N, H));
    half NoV = saturate(abs(dot(N, V)) + 1e-5);
    half NoL = saturate(dot(N, L));
    half VoH = saturate(dot(V, H));
    half3 fixedLightCol = light.color * light.shadowAttenuation * light.distanceAttenuation;

    // 虹膜，焦散 参考UE4代码：EyeBxDF
	half NoL_iris = saturate(dot(irisNormal, L));
	half power = lerp(12, 1, NoL_iris);
	half caustic = 0.3 + (0.8 + 0.2 * (power + 1 )) * pow(saturate(dot(causticNormal, L)), power);
	NoL_iris = NoL_iris * caustic;

    // 漫反射
    half NoL_diff = lerp(NoL, NoL_iris, irisMask);
    half3 diffLighting = Diffuse_LambertNoPI(diffCol) * NoL_diff * fixedLightCol;

    // 角膜镜面反射
    half D_cornea = D_GGX_ue4(a2, NoH);
    half Vis_cornea = Vis_SmithJointApprox(a2, NoV, NoL);
    half3 F_cornea = F_Schlick_ue4(specCol, VoH) * irisMask;
    half3 specLighting_cornea = (D_cornea * Vis_cornea * F_cornea) * NoL * fixedLightCol * PI;
    half3 lossEnergy = F_cornea;

    half3 brdf = half3(0,0,0);
    brdf += diffLighting * (1 - lossEnergy);
    brdf += specLighting_cornea;

    return brdf;
}

half3 DirectLighting_Eye(half3 diffCol, half3 specCol, float3 worldPos, half3 N, half3 irisNormal, half3 causticNormal, half roughness, half irisMask)
{
    half a2 = Pow4(roughness);
    float4 shadowCoord = CalculateShadowCoord_unity(worldPos);
    Light mainLight = GetMainLight(shadowCoord);

    half3 directLighting = BRDF_Eye(mainLight, diffCol, specCol, worldPos, N, irisNormal, causticNormal, a2, irisMask);

    #ifdef _ADDITIONAL_LIGHTS
        uint addLightCount = GetAdditionalLightsCount();
        for(uint lightIndex = 0; lightIndex < addLightCount; ++lightIndex)
        {
            Light addLight = GetAdditionalLight(lightIndex, worldPos);
            directLighting += BRDF_Eye(addLight, diffCol, specCol, worldPos, N, irisNormal, causticNormal, a2, irisMask);
        }
    #endif

    return directLighting;
}

half3 IndirectLighting_Eye(half3 diffCol, half3 specCol, float3 worldPos, half3 N, half roughness, float envRotation)
{
    half3 V = GetWorldSpaceNormalizeViewDir(worldPos);
    half NoV = saturate(abs(dot(N, V))+1e-5);

    // SH
    half3 sh = SampleSH(N);
    half3 diffLighting = diffCol * sh;

    // LD IBL
    half3 reflectDir = reflect(-V, N);
    reflectDir = RotateDirection(reflectDir, envRotation);
    half3 specLD = GlossyEnvironmentReflection(reflectDir, worldPos, roughness, 1);

    // DFG
    half3 specDFG = EnvBRDFApprox(specCol, roughness, NoV);
    half3 specLighting = specLD * specDFG;

    half3 indirectLighting = diffLighting + specLighting;
    return indirectLighting;
}

half3 PBRLighting_Eye(half3 diffCol, half3 specCol, float3 worldPos, half3 N, half3 irisNormal, half3 causticNormal, half irisMask, float envRotation)
{
    half roughness = lerp(0.1, 0.01, irisMask);
    half3 lighting = half3(0,0,0);
    half3 directLighting = DirectLighting_Eye(diffCol, specCol, worldPos, N, irisNormal, causticNormal, roughness, irisMask);
    lighting += directLighting;
    half3 indirectLighting = IndirectLighting_Eye(diffCol, specCol, worldPos, N, roughness, envRotation);
    lighting += indirectLighting;
    return lighting;
}