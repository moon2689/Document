#include "PBRBRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

float3 DirectLighting_Iridescence(Light light, float3 diffCol, float3 specCol, float3 N, float3 worldPos, float3 V, float a2,
                                float occlusion, float iridescence, float iridescenceThickness)
{
    float3 L = light.direction;
    float3 H = normalize(L + V);
    float NoH = saturate(dot(N, H));
    float NoV = saturate(abs(dot(N, V)) + 1e-5);
    float NoL = saturate(dot(N, L));
    float VoH = saturate(dot(V, H));
    half3 radiance = NoL * light.color * light.shadowAttenuation * light.distanceAttenuation * occlusion * PI;

    // ¬˛∑¥…‰
    float3 diffuseLighting = Diffuse_Lambert(diffCol);

    // æµ√Ê∑¥…‰
    float D = D_GGX_ue4(a2, NoH);
    float Vis = Vis_SmithJointApprox(a2, NoV, NoL);
    float3 F = F_Schlick_ue4(specCol, VoH);

    // ¿ÿ…‰
    float3 F_Iridescence = EvalIridescence(1, NoV, iridescenceThickness, specCol);
    float3 F_Lerp = lerp(F, F_Iridescence, iridescence);

    float3 specLighting = D * Vis * F_Lerp;

    float3 lighting = (diffuseLighting + specLighting) * radiance;
    return lighting;
}

float3 AllDirectLighting_Iridescence(float3 diffCol, float3 specCol, float3 N, float3 worldPos, float3 V, float roughness,
                                    float occlusion, float iridescence, float iridescenceThickness)
{
    float a2 = Pow4(roughness);
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
    Light mainLight = GetMainLight(shadowCoord);

    float3 directLighting = DirectLighting_Iridescence(mainLight, diffCol, specCol, N, worldPos, V, a2, occlusion, iridescence, iridescenceThickness);

    #ifdef _ADDITIONAL_LIGHTS
        uint addLightCount = GetAdditionalLightsCount();
        for(uint lightIndex = 0; lightIndex < addLightCount; ++lightIndex)
        {
            Light addLight = GetAdditionalLight(lightIndex, worldPos);
            directLighting += DirectLighting_Iridescence(addLight, diffCol, specCol, N, worldPos, V, a2, occlusion, iridescence, iridescenceThickness);
        }
    #endif
    return directLighting;
}

float3 IndirectLighting_Iridescence(float3 diffCol, float3 specCol, float3 N, float3 worldPos, float3 V, float roughness,
                                    float occlusion, float iridescenceIBL, float iridescenceThickness)
{
    float NoV = saturate(abs(dot(N, V))+1e-5);

    // SH
    half3 sh = SampleSH(N);
    half3 diffuseLighting = diffCol * sh;

    // LD IBL
    half3 reflectDir = reflect(-V, N);
    half3 specLD = GlossyEnvironmentReflection(reflectDir, worldPos, roughness, occlusion);

    // ¿ÿ…‰
    float3 F_Iridescence = EvalIridescence(1, NoV, iridescenceThickness, specCol);
    specCol = lerp(specCol, F_Iridescence, iridescenceIBL);

    // DFG
    half3 specDFG = EnvBRDFApprox(specCol, roughness, NoV);
    half3 specLighting = specLD * specDFG;

    float3 indirectLighting = diffuseLighting + specLighting;
    return indirectLighting;
}

float3 PBRLighting_Iridescence(float3 diffCol, float3 specCol, float3 N, float3 worldPos, float roughness,
                            float occlusion, float iridescence, float iridescenceIBL, float iridescenceThickness)
{
    float3 V = GetWorldSpaceNormalizeViewDir(worldPos);
    float3 lightingCol = float3(0, 0, 0);
    float3 directLighting = AllDirectLighting_Iridescence(diffCol, specCol, N, worldPos, V, roughness, occlusion, iridescence, iridescenceThickness);
    lightingCol += directLighting;
    float3 indirectLighting = IndirectLighting_Iridescence(diffCol, specCol, N, worldPos, V, roughness, occlusion, iridescenceIBL, iridescenceThickness);
    lightingCol += indirectLighting;
    return lightingCol;
}