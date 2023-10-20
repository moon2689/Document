#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

half4 CalculateShadowMask_unity(half4 oldShadowMask)
{
    // To ensure backward compatibility we have to avoid using shadowMask input, as it is not present in older shaders
    #if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
    half4 shadowMask = oldShadowMask;
    #elif !defined (LIGHTMAP_ON)
    half4 shadowMask = unity_ProbesOcclusion;
    #else
    half4 shadowMask = half4(1, 1, 1, 1);
    #endif

    return shadowMask;
}

half3 GlobalIllumination_unity(half3 diffCol, half3 specCol, float3 positionWS, half3 N, half3 V, half occlusion, half roughness, half roughnessPow4, half grazingTerm)
{
    half3 reflectVector = reflect(-V, N);
    half NoV = saturate(dot(N, V));
    half fresnelTerm = Pow4(1.0 - NoV);

    half3 indirectDiffuse = SampleSH(N);
    half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, positionWS, roughness, 1.0h);

    // Computes the specular term for EnvironmentBRDF
    float surfaceReduction = 1.0 / (roughnessPow4 + 1.0);
    half3 brdfSpec = half3(surfaceReduction * lerp(specCol, grazingTerm, fresnelTerm));

    half3 c = indirectDiffuse * diffCol;
    c += indirectSpecular * brdfSpec;
    return c * occlusion;
}

// Computes the scalar specular term for Minimalist CookTorrance BRDF
// NOTE: needs to be multiplied with reflectance f0, i.e. specular color to complete
half DirectBRDFSpecular_unity(half3 N, half3 L, half3 V, half roughnessPow2, half roughnessPow4)
{
    float3 halfDir = SafeNormalize(L + float3(V));

    float NoH = saturate(dot(float3(N), halfDir));
    half LoH = half(saturate(dot(L, halfDir)));

    // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
    // BRDFspec = (D * V * F) / 4.0
    // D = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2
    // V * F = 1.0 / ( LoH^2 * (roughness + 0.5) )
    // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
    // https://community.arm.com/events/1155

    // Final BRDFspec = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2 * (LoH^2 * (roughness + 0.5) * 4.0)
    // We further optimize a few light invariant terms
    // brdfData.normalizationTerm = (roughness + 0.5) * 4.0 rewritten as roughness * 4.0 + 2.0 to a fit a MAD.
    half normalizationTerm = roughnessPow2 * 4 + 2;
    float d = NoH * NoH * (roughnessPow4 - 1) + 1.00001f;

    half LoH2 = LoH * LoH;
    half specularTerm = roughnessPow4 / ((d * d) * max(0.1h, LoH2) * normalizationTerm);

    // On platforms where half actually means something, the denominator has a risk of overflow
    // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
    // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
#if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
    specularTerm = specularTerm - HALF_MIN;
    specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
#endif

return specularTerm;
}

half3 LightingPhysicallyBased_unity(half3 diffCol, half3 specCol, Light light, half3 N, half3 V, half roughnessPow2, half roughnessPow4)
{
    half3 L = light.direction;
    half NdotL = saturate(dot(N, L));
    half3 radiance = light.color * (light.distanceAttenuation * light.shadowAttenuation * NdotL);

    half3 brdf = diffCol;
    brdf += specCol* DirectBRDFSpecular_unity(N, L, V, roughnessPow2, roughnessPow4);

    return brdf * radiance;
}

half3 UniversalFragmentPBR_unity(float3 positionWS, float3 N, half3 diffCol, half3 specCol, half metallic, half roughness, half occlusion)
{
//#ifdef _SPECULAR_SETUP
//    half reflectivity = ReflectivitySpecular(specular);
//    half oneMinusReflectivity = half(1.0) - reflectivity;
//    half3 brdfDiffuse = albedo * (half3(1.0, 1.0, 1.0) - specular);
//    half3 brdfSpecular = specular;
//#else
    half oneMinusReflectivity = OneMinusReflectivityMetallic(metallic);
    half reflectivity = half(1.0) - oneMinusReflectivity;
    half3 brdfDiffuse = diffCol * oneMinusReflectivity;
    half3 brdfSpecular = lerp(kDieletricSpec.rgb, diffCol, metallic);
//#endif

    half roughnessPow2 = max(roughness * roughness, HALF_MIN_SQRT);
    half roughnessPow4 = max(roughnessPow2 * roughnessPow2, HALF_MIN);
    half grazingTerm = saturate(1 - roughness + reflectivity);
    float3 V = GetWorldSpaceNormalizeViewDir(positionWS);

    // GI color
    half3 giColor = GlobalIllumination_unity(brdfDiffuse, brdfSpecular, positionWS, N, V, occlusion, roughness, roughnessPow4, grazingTerm);

    // Main light
    half4 shadowMask = CalculateShadowMask_unity(half4(1,1,1,1));
    half4 shadowCoord = TransformWorldToShadowCoord(positionWS);
    Light mainLight = GetMainLight(shadowCoord, positionWS, shadowMask);
    half3 mainLightColor = LightingPhysicallyBased_unity(brdfDiffuse, brdfSpecular, mainLight, N, V, roughnessPow2, roughnessPow4);

    // Additional light
    half3 addLightColor = half3(0, 0, 0);
    #if defined(_ADDITIONAL_LIGHTS)
        uint pixelLightCount = GetAdditionalLightsCount();
        for(uint lightIndex = 0; lightIndex < pixelLightCount; ++lightIndex)
        {
            Light addLight = GetAdditionalLight(lightIndex, positionWS, shadowMask);
            addLightColor += LightingPhysicallyBased_unity(brdfDiffuse, brdfSpecular, addLight, N, V, roughnessPow2, roughnessPow4);
        }
    #endif

    half3 lightingColor = 0;
    lightingColor += giColor;
    lightingColor += mainLightColor;
    lightingColor += addLightColor;
    return lightingColor;
}

half4 UniversalFragmentPBR_unity(InputData inputData, SurfaceData surfaceData)
{
    float3 positionWS = inputData.positionWS;
    float3 N = inputData.normalWS;
    half3 diffCol = surfaceData.albedo;
    half3 specCol = surfaceData.specular;
    half metallic = surfaceData.metallic;
    half roughness = 1 - surfaceData.smoothness;
    half occlusion = surfaceData.occlusion;

    half4 color;
    color.rgb = UniversalFragmentPBR_unity(positionWS, N, diffCol, specCol, metallic, roughness, occlusion);
    color.a = surfaceData.alpha;
    return color;
}