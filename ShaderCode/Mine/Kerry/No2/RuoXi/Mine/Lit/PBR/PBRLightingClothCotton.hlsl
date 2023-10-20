#include "PBRBRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

float3 DirectLighting_Cotton(Light light, float3 diffCol, float3 sheenCol, float3 worldNormal, float3 worldPos, float3 viewDir,
                            float roughness, float occlusion, float sheenRoughness, float sheenDFG)
{
    float3 L = light.direction;
    float3 V = viewDir;
    float3 H = normalize(L + V);
    float3 N = worldNormal;
    float NoH = saturate(dot(N, H));
    float NoV = saturate(abs(dot(N, V)) + 1e-5);
    float NoL = saturate(dot(N, L));
    float VoH = saturate(dot(V, H));
    half3 radiance = NoL * light.color * light.shadowAttenuation * light.distanceAttenuation * occlusion * PI;

    // Âþ·´Éä
    float3 diffuseLighting = Diffuse_Lambert(diffCol) * radiance;

    // ¾µÃæ·´Éä
    //float D = D_GGX_ue4(a2, NoH);
    //float Vis = Vis_SmithJointApprox(a2, NoV, NoL);
    //float3 F = F_Schlick_ue4(specCol, VoH);
    float D = D_Charlie_Filament(roughness, NoH);
    float Vis = Vis_Cloth(NoV, NoL);
    float3 F = F_Schlick_ue4(0.04.xxx, VoH);
    float3 specLighting = (D * Vis * F) * radiance;

    // sheen color
    //float D = D_InvGGX(a2, NoH);
    float sheenD = D_Charlie_Filament(sheenRoughness, NoH);
    float3 sheenF = sheenCol;
    float3 sheenSpecLighting = (sheenD * Vis * sheenF) * radiance;
    half lossEnergy = max(max(sheenCol.r, sheenCol.g), sheenCol.b) * sheenDFG;

    float3 lighting = (diffuseLighting + specLighting) * (1 - lossEnergy) + sheenSpecLighting;
    //lighting = D.xxx;
    return lighting;
}

float3 AllDirectLighting_Cotton(float3 diffCol, float3 sheenCol, float3 worldNormal, float3 worldPos, float3 viewDir,
                                float roughness, float occlusion,float sheenRoughness, float sheenDFG)
{
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
    Light mainLight = GetMainLight(shadowCoord);

    float3 directLighting = DirectLighting_Cotton(mainLight, diffCol, sheenCol, worldNormal, worldPos, viewDir, roughness, occlusion, sheenRoughness, sheenDFG);

    #ifdef _ADDITIONAL_LIGHTS
        uint addLightCount = GetAdditionalLightsCount();
        for(uint lightIndex = 0; lightIndex < addLightCount; ++lightIndex)
        {
            Light addLight = GetAdditionalLight(lightIndex, worldPos);
            directLighting += DirectLighting_Cotton(addLight, diffCol, sheenCol, worldNormal, worldPos, viewDir, roughness, occlusion, sheenRoughness, sheenDFG);
        }
    #endif

    return directLighting;
}

float3 IndirectLighting_Cotton(float3 diffCol, float3 sheenCol, float3 worldNormal, float3 worldPos, float3 viewDir, float roughness, float occlusion,float sheenDFG)
{
    float3 V = viewDir;
    float3 N = worldNormal;
    float NoV = saturate(abs(dot(N, V))+1e-5);

    // SH
    half3 sh = SampleSH(N);
    half3 diffuseLighting = diffCol * sh;

    // LD IBL
    half3 reflectDir = reflect(-V, N);
    half3 specLD = GlossyEnvironmentReflection(reflectDir, worldPos, roughness, occlusion);
    //half3 specDFG = EnvBRDFApprox(sheenCol, roughness, NoV);
    half3 specDFG = 0.04.xxx * sheenDFG;
    half3 specLighting = specLD * specDFG;

    // DFG
    half3 sheenSpecDFG = sheenCol * sheenDFG;
    half3 sheenSpecLighting = specLD * sheenSpecDFG;
    half lossEnergy = max(max(sheenCol.r, sheenCol.g), sheenCol.b) * sheenDFG;

    float3 indirectLighting = (diffuseLighting + specLighting) * (1 - lossEnergy) + sheenSpecLighting;
    return indirectLighting;
}

float3 PBRLighting_Cotton(float3 diffCol, float3 sheenCol, float3 worldNormal, float3 worldPos, float roughness, float occlusion,float sheenRoughness, float sheenDFG)
{
    float3 viewDir = GetWorldSpaceNormalizeViewDir(worldPos);
    float3 directLighting = AllDirectLighting_Cotton(diffCol, sheenCol, worldNormal, worldPos, viewDir, roughness, occlusion, sheenRoughness, sheenDFG);
    float3 indirectLighting = IndirectLighting_Cotton(diffCol, sheenCol, worldNormal, worldPos, viewDir, roughness, occlusion, sheenDFG);
    //directLighting = float3(0,0,0);
    return directLighting + indirectLighting;
}