#include "PBRBRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


///////////////////////////// Face ///////////////////////////////
half3 BRDF_Skin(Light light, half3 diffCol, half3 specCol, float3 worldPos, half3 N, half3 V, half3 N_blur,
                half lobe1A2, half lobe2A2, half occlusion, half curvature, Texture2D sssLutTex, SamplerState sampler_sssLut)
{
    half3 L = light.direction;
    half3 H = normalize(L + V);
    half NoH = saturate(dot(N, H));
    half NoV = saturate(abs(dot(N, V)) + 1e-5);
    half NoL = saturate(dot(N, L));
    half VoH = saturate(dot(V, H));

    half shadowRatio = saturate(light.shadowAttenuation + 0.2) * light.distanceAttenuation;
	half3 diffuseShadow = lerp(half3(0.11,0.025,0.012), half3(1,1,1), shadowRatio); //hard code
    half3 lightCol = light.color * diffuseShadow * occlusion;

    half3 brdf = half3(0, 0, 0);
    
    // Âþ·´Éä
    half2 uv_sssLut = half2(dot(N_blur, L) * 0.5 + 0.5, curvature);
    half3 sssCol = SAMPLE_TEXTURE2D(sssLutTex, sampler_sssLut, uv_sssLut).rgb;
    half3 diffuseLighting = Diffuse_LambertNoPI(diffCol) * sssCol * lightCol;
    brdf += diffuseLighting;

    // ¾µÃæ·´Éä
    half D = lerp(D_GGX_ue4(lobe1A2, NoH), D_GGX_ue4(lobe2A2, NoH), 0.15);
    half Vis = lerp(Vis_SmithJointApprox(lobe1A2, NoV, NoL), Vis_SmithJointApprox(lobe2A2, NoV, NoL), 0.15);
    half3 F = F_Schlick_ue4(specCol, VoH);
    half3 specLighting = (D * Vis * F * PI) * NoL * lightCol;
    brdf += specLighting;

    return brdf;
}

half3 DirectLighting_Skin(half3 diffCol, half3 specCol, float3 worldPos, half3 N, half3 V, half3 N_blur,
                        half lobe1Roughness, half lobe2Roughness, half occlusion, half curvature, Texture2D sssLutTex, SamplerState sampler_sssLut)
{
    half lobe1A2 = Pow4_ue4(lobe1Roughness);
    half lobe2A2 = Pow4_ue4(lobe2Roughness);
    half4 shadowMask = CalculateShadowMask_unity();
    float4 shadowCoord = CalculateShadowCoord_unity(worldPos);
    Light mainLight = GetMainLight(shadowCoord, worldPos, shadowMask);

    half3 directLighting = BRDF_Skin(mainLight, diffCol, specCol, worldPos, N, V, N_blur, lobe1A2, lobe2A2, occlusion, curvature, sssLutTex, sampler_sssLut);

    #ifdef _ADDITIONAL_LIGHTS
        uint addLightCount = GetAdditionalLightsCount();
        for(uint lightIndex = 0; lightIndex < addLightCount; ++lightIndex)
        {
            Light addLight = GetAdditionalLight(lightIndex, worldPos, shadowMask);
            directLighting += BRDF_Skin(addLight, diffCol, specCol, worldPos, N, V, N_blur, lobe1A2, lobe2A2, occlusion, curvature, sssLutTex, sampler_sssLut);
        }
    #endif

    return directLighting;
}

half3 EnvSpecLighting(half3 specCol, float3 worldPos, half3 N, half3 V, half roughness, half occlusion)
{
    half NoV = saturate(abs(dot(N, V))+1e-5);

    // LD IBL
    half3 reflectDir = reflect(-V, N);
    half3 specLD = GlossyEnvironmentReflection(reflectDir, worldPos, roughness, occlusion);

    // DFG
    half3 specDFG = EnvBRDFApprox(specCol, roughness, NoV);
    half3 specLighting = specLD * specDFG;

    return specLighting;
}

half3 IndirectLighting_Skin(half3 diffCol, half3 specCol, float3 worldPos, half3 N, half3 V,
                        half lobe1Roughness, half lobe2Roughness, half occlusion)
{
    // SH
    half3 sh = SampleSH(N);
    half3 diffuseLighting = diffCol * sh;
    half VoN = saturate(dot(V, N));

    // spec
    half3 spec1Col = EnvSpecLighting(specCol, N, V, worldPos, lobe1Roughness, occlusion);
    half3 spec2Col = EnvSpecLighting(specCol, N, V, worldPos, lobe2Roughness, occlusion);
    half3 specLighting = lerp(spec1Col, spec2Col, 0.15);

    half3 indirectLighting = diffuseLighting + specLighting;
    return indirectLighting;
}

half3 PBRLighting_Skin(half3 diffCol, half3 specCol, float3 worldPos, half3 N, half3 N_blur,
                        half lobe1Roughness, half lobe2Roughness, half occlusion,
                        half curvature, Texture2D sssLutTex, SamplerState sampler_sssLut)
{
    lobe1Roughness = max(0.05, lobe1Roughness);
    lobe2Roughness = max(0.05, lobe2Roughness);

    half3 V = GetWorldSpaceNormalizeViewDir(worldPos);

    half3 lightingCol = half3(0, 0, 0);
    half3 directLighting = DirectLighting_Skin(diffCol, specCol, worldPos, N, V, N_blur, lobe1Roughness, lobe2Roughness, occlusion, curvature, sssLutTex, sampler_sssLut);
    lightingCol += directLighting;
    half3 indirectLighting = IndirectLighting_Skin(diffCol, specCol, worldPos, N, V, lobe1Roughness, lobe2Roughness, occlusion);
    lightingCol += indirectLighting;
    return lightingCol;
}
