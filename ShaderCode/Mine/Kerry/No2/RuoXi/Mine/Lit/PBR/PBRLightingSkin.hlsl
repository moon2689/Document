#include "PBRBRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


///////////////////////////// Face ///////////////////////////////
float3 DirectLighting_Skin(Light light, float3 diffCol, float3 specCol, float3 N, float3 V, float3 N_blur, float3 worldPos,
                float lobe1A2, float lobe2A2, float lobe2Weight,
                float occlusion, Texture2D sssLutTex, SamplerState sampler_sssLut,
                float clearCoatIntensity, float clearCoatA2)
{
    float3 L = light.direction;
    float3 H = normalize(L + V);
    float NoH = saturate(dot(N, H));
    float NoV = saturate(abs(dot(N, V)) + 1e-5);
    float NoL = saturate(dot(N, L));
    float VoH = saturate(dot(V, H));

    half shadowRatio = saturate(light.shadowAttenuation + 0.2) * light.distanceAttenuation;
	half3 diffuseShadow = lerp(half3(0.11,0.025,0.012), float3(1,1,1), shadowRatio); //hard code
    float3 newLightCol = light.color * diffuseShadow * occlusion * PI;

    // Âþ·´Éä
    float2 uv_sssLut = float2(dot(N_blur, L) * 0.5 + 0.5, 0.5);
    float3 sssCol = SAMPLE_TEXTURE2D(sssLutTex, sampler_sssLut, uv_sssLut);

    float3 diffuseLighting = Diffuse_Lambert(diffCol) * sssCol * newLightCol;

    // ¾µÃæ·´Éä
    float D = lerp(D_GGX_ue4(lobe1A2, NoH), D_GGX_ue4(lobe2A2, NoH), lobe2Weight);
    float Vis = lerp(Vis_SmithJointApprox(lobe1A2, NoV, NoL), Vis_SmithJointApprox(lobe2A2, NoV, NoL), lobe2Weight);
    float3 F = F_Schlick_ue4(specCol, VoH);
    float3 specLighting = (D * Vis * F) * NoL * newLightCol;

    // clear coat
    float D_clearCoat = D_GGX_ue4(clearCoatA2, NoH);
    float Vis_clearCoat = Vis_SmithJointApprox(clearCoatA2, NoV, NoL);
    float3 F_clearCoat = F_Schlick_ue4(half3(0.04, 0.04, 0.04), VoH) * clearCoatIntensity;
    float3 specLighting_clearCoat = (D_clearCoat * Vis_clearCoat * F_clearCoat) *NoL * newLightCol;
    float3 lossEnergy = F_clearCoat;

    float3 brdf = (diffuseLighting + specLighting) * (1 - lossEnergy) + specLighting_clearCoat;
    //brdf = specLighting_clearCoat;
    return brdf;
}

float3 AllDirectLighting_Skin(float3 diffCol, float3 specCol, float3 N, float3 V, float3 N_blur, float3 worldPos, 
                            float lobe1Roughness, float lobe2Roughness, float lobe2Weight,
                            float occlusion, Texture2D sssLutTex, SamplerState sampler_sssLut,
                            float clearCoatIntensity, float clearCoatRoughness)
{
    float lobe1A2 = Pow4(lobe1Roughness);
    float lobe2A2 = Pow4(lobe2Roughness);
    float clearCoatA2 = Pow4(clearCoatRoughness);
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
    Light mainLight = GetMainLight(shadowCoord);

    float3 directLighting = DirectLighting_Skin(mainLight, diffCol, specCol, N, V, N_blur, worldPos, lobe1A2, lobe2A2, lobe2Weight, occlusion, sssLutTex, sampler_sssLut, clearCoatIntensity, clearCoatA2);

    #ifdef _ADDITIONAL_LIGHTS
        uint addLightCount = GetAdditionalLightsCount();
        for(uint lightIndex = 0; lightIndex < addLightCount; ++lightIndex)
        {
            Light addLight = GetAdditionalLight(lightIndex, worldPos);
            directLighting += DirectLighting_Skin(addLight, diffCol, specCol, N, V, N_blur, worldPos, lobe1A2, lobe2A2, lobe2Weight, occlusion, sssLutTex, sampler_sssLut, clearCoatIntensity, clearCoatA2);
        }
    #endif

    return directLighting;
}

float3 EnvSpecLighting(float3 specCol, float3 N, float3 V, float3 worldPos,float roughness, float occlusion)
{
    float NoV = saturate(abs(dot(N, V))+1e-5);


    // LD IBL
    half3 reflectDir = reflect(-V, N);
    half3 specLD = GlossyEnvironmentReflection(reflectDir, worldPos, roughness, occlusion);

    // DFG
    half3 specDFG = EnvBRDFApprox(specCol, roughness, NoV);
    half3 specLighting = specLD * specDFG;

    return specLighting;
}

float3 IndirectLighting_Skin(float3 diffCol, float3 specCol, float3 N, float3 V, float3 worldPos,
                        float lobe1Roughness, float lobe2Roughness, float lobe2Weight, float occlusion,
                        float clearCoatIntensity, float clearCoatRoughness)
{
    // SH
    half3 sh = SampleSH(N);
    half3 diffuseLighting = diffCol * sh;
    float VoN = saturate(dot(V, N));

    // spec
    half3 spec1Col = EnvSpecLighting(specCol, N, V, worldPos, lobe1Roughness, occlusion);
    half3 spec2Col = EnvSpecLighting(specCol, N, V, worldPos, lobe2Roughness, occlusion);
    half3 specLighting = lerp(spec1Col, spec2Col, lobe2Weight);

    // clear coat spec
    half3 specCol_clearCoat = EnvSpecLighting(half3(0.04, 0.04, 0.04), N, V, worldPos, clearCoatRoughness, occlusion) * clearCoatIntensity;
    float3 lossEnergy = F_Schlick_ue4(half3(0.04, 0.04, 0.04), VoN) * clearCoatIntensity;

    float3 indirectLighting = (diffuseLighting + specLighting) * (1 - lossEnergy) + specCol_clearCoat;
    return indirectLighting;
}

float3 PBRLighting_Skin(float3 diffCol, float3 specCol, float3 N, float3 N_blur, float3 worldPos, 
                        float lobe1Roughness, float lobe2Roughness, float lobe2Weight,
                        float occlusion, Texture2D sssLutTex, SamplerState sampler_sssLut,
                        float clearCoatIntensity, float clearCoatRoughness)
{
    float3 V = GetWorldSpaceNormalizeViewDir(worldPos);
    float3 lightingCol = float3(0, 0, 0);
    float3 directLighting = AllDirectLighting_Skin(diffCol, specCol, N, V, N_blur, worldPos, lobe1Roughness, lobe2Roughness, lobe2Weight, occlusion, sssLutTex, sampler_sssLut, clearCoatIntensity, clearCoatRoughness);
    lightingCol += directLighting;
    float3 indirectLighting = IndirectLighting_Skin(diffCol, specCol, N, V, worldPos, lobe1Roughness, lobe2Roughness, lobe2Weight, occlusion, clearCoatIntensity, clearCoatRoughness);
    lightingCol += indirectLighting;
    return lightingCol;
}
