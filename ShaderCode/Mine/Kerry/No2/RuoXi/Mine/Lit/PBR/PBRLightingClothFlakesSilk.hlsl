//#include "PBRBRDF.hlsl"
#include "PBRLightingClothSilk.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


float3 SpecularLighting_Flakes(float3 specCol, float3 N, float3 V, float3 L, float a2)
{
    float3 H = normalize(L + V);
    float NoH = saturate(dot(N, H));
    float NoV = saturate(abs(dot(N, V)) + 1e-5);
    float NoL = saturate(dot(N, L));
    float VoH = saturate(dot(V, H));

    float3 newLightCol = specCol * PI;

    // æµ√Ê∑¥…‰
    float D = D_GGX_ue4(a2, NoH);
    float Vis = Vis_SmithJointApprox(a2, NoV, NoL);
    float3 F = F_Schlick_ue4(specCol, VoH);
    float3 specLighting = (D * Vis * F) * NoL * newLightCol;

    return specLighting;
}

float3 AllSpecularLighting_Flakes(float3 specCol, float3 N, float3 worldPos, float roughness)
{
    float3 V = GetWorldSpaceNormalizeViewDir(worldPos);
    float a2 = Pow4(roughness);
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
    Light mainLight = GetMainLight(shadowCoord);

    float3 directLighting = SpecularLighting_Flakes(specCol, N, V, mainLight.direction, a2);

    #ifdef _ADDITIONAL_LIGHTS
        uint addLightCount = GetAdditionalLightsCount();
        for(uint lightIndex = 0; lightIndex < addLightCount; ++lightIndex)
        {
            Light addLight = GetAdditionalLight(lightIndex, worldPos);
            directLighting += SpecularLighting_Flakes(specCol, N, V, addLight.direction, a2);
        }
    #endif

    return directLighting;
}

float3 PBRLighting_FlakesSilk(float3 diffCol, float3 specCol, float3 worldPos, float3 N, float3 T, float3 B, float roughness, float aniso,
                                float3 flakesSpecCol, float3 flakesNormal, float flakesRoughness)
{
    float3 finalLighting = float3(0, 0, 0);
    float3 lightingSilk = PBRLighting_Silk(diffCol, specCol, worldPos, N, T, B, roughness, aniso);
    finalLighting += lightingSilk;
    float3 lightingFlakes = AllSpecularLighting_Flakes(flakesSpecCol, flakesNormal, worldPos, flakesRoughness);
    finalLighting += lightingFlakes;
    return finalLighting;
}