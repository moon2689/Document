#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "PBRBRDF.hlsl"

half3 BRDF_Standard(Light light, half3 diffCol, half3 specCol, float3 worldPos, half3 N, half3 V, half a2, half occlusion)
{
    half3 L = light.direction;
    half3 H = normalize(L + V);
    half NoH = saturate(dot(N, H));
    half NoV = saturate(abs(dot(N, V)) + 1e-5);
    half NoL = saturate(dot(N, L));
    half VoH = saturate(dot(V, H));
    half3 radiance = NoL * light.color * light.shadowAttenuation * light.distanceAttenuation * occlusion * PI;
    half3 brdf = half3(0, 0, 0);

    // Âþ·´Éä
    half3 diffuseLighting = Diffuse_Lambert(diffCol) * radiance;
    brdf += diffuseLighting;

    // ¾µÃæ·´Éä
    half D = D_GGX_ue4(a2, NoH);
    half Vis = Vis_SmithJointApprox(a2, NoV, NoL);
    half3 F = F_Schlick_ue4(specCol, VoH);
    half3 specLighting = D * Vis * F * radiance;
    brdf += specLighting;

    return brdf;
}

half3 DirectLighting_Standard(half3 diffCol, half3 specCol, float3 worldPos, half3 N, half3 V, half roughness, half occlusion)
{
    half a2 = Pow4(roughness);
    float4 shadowCoord = CalculateShadowCoord_unity(worldPos);
    Light mainLight = GetMainLight(shadowCoord);

    half3 directLighting = BRDF_Standard(mainLight, diffCol, specCol, worldPos, N, V, a2, occlusion);

    #ifdef _ADDITIONAL_LIGHTS
        uint addLightCount = GetAdditionalLightsCount();
        for(uint lightIndex = 0; lightIndex < addLightCount; ++lightIndex)
        {
            Light addLight = GetAdditionalLight(lightIndex, worldPos);
            directLighting += BRDF_Standard(addLight, diffCol, specCol, worldPos, N, V, a2, occlusion);
        }
    #endif

    return directLighting;
}

half3 IndirectLighting_Standard(half3 diffCol, half3 specCol, float3 worldPos, half3 N, half3 V, half roughness, half occlusion)
{
    half NoV = saturate(abs(dot(N, V))+1e-5);

    // SH
    half3 sh = SampleSH(N);
    half3 diffuseLighting = diffCol * sh;

    // LD IBL
    half3 reflectDir = reflect(-V, N);
    reflectDir = RotateDirection(reflectDir, 0);
    half3 specLD = GlossyEnvironmentReflection(reflectDir, worldPos, roughness, occlusion);

    // DFG
    half3 specDFG = EnvBRDFApprox(specCol, roughness, NoV);
    half3 specLighting = specLD * specDFG;

    half3 indirectLighting = diffuseLighting + specLighting;
    return indirectLighting;
}

half3 PBRLighting_Standard(half3 diffCol, half3 specCol, float3 worldPos, half3 N, half roughness, half occlusion)
{
    half3 V = GetWorldSpaceNormalizeViewDir(worldPos);
    half3 lighting = half3(0, 0, 0);
    half3 directLighting = DirectLighting_Standard(diffCol, specCol, worldPos, N, V, roughness, occlusion);
    lighting += directLighting;
    half3 indirectLighting = IndirectLighting_Standard(diffCol, specCol, worldPos, N, V, roughness, occlusion);
    lighting += indirectLighting;
    return lighting;
}