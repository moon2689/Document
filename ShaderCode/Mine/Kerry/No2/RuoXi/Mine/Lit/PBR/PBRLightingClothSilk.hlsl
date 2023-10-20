#include "PBRBRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

float3 DirectLighting_Silk(Light light, float3 diffCol, float3 specCol, float3 worldPos, float3 N, float3 T, float3 B, float3 V, float roughness, float aniso)
{
    float3 L = light.direction;
    float3 H = normalize(L + V);
    float NoH = saturate(dot(N, H));
    float NoV = saturate(abs(dot(N, V)) + 1e-5);
    float NoL = saturate(dot(N, L));
    float VoH = saturate(dot(V, H));
    float a = Pow2(roughness);
    half3 radiance = NoL * light.color * light.shadowAttenuation * light.distanceAttenuation * PI;

    // 这里参考UE4代码GetAnisotropicRoughness
    // Anisotropic parameters: ax and ay are the roughness along the tangent and bitangent	
	// Kulla 2017, "Revisiting Physically Based Shading at Imageworks"
    float ax = max(a * (1 + aniso), 0.001);
    float ay = max(a * (1 - aniso), 0.001);

    float3 X = T;
    float3 Y = B;
    float XoV = dot(X, V);
    float XoL = dot(X, L);
    float XoH = dot(X, H);
    float YoV = dot(Y, V);
    float YoL = dot(Y, L);
    float YoH = dot(Y, H);

    // 漫反射
    float3 lighting = float3(0,0,0);
    float3 diffLighting = Diffuse_Lambert(diffCol) * radiance;
    lighting += diffLighting;

    // 各向异性高光，参考UE4代码SpecularGGX
    float D = D_GGXaniso(ax, ay, NoH, XoH, YoH);
    float Vis = Vis_SmithJointAniso(ax, ay, NoV, NoL, XoV, XoL, YoV, YoL);
    float3 F = F_Schlick_ue4(specCol, VoH);
    float3 specLighting = (D * Vis * F) * radiance;
    lighting += specLighting;

    return lighting;
}

float3 AllDirectLighting_Silk(float3 diffCol, float3 specCol, float3 worldPos, float3 N, float3 T, float3 B, float3 V, float roughness, float aniso)
{
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
    Light mainLight = GetMainLight(shadowCoord);

    float3 directLighting = DirectLighting_Silk(mainLight, diffCol, specCol, worldPos, N, T, B, V, roughness, aniso);

    #ifdef _ADDITIONAL_LIGHTS
        uint addLightCount = GetAdditionalLightsCount();
        for(uint lightIndex = 0; lightIndex < addLightCount; ++lightIndex)
        {
            Light addLight = GetAdditionalLight(lightIndex, worldPos);
            directLighting += DirectLighting_Silk(addLight, diffCol, specCol, worldPos, N, T, B, V, roughness, aniso);
        }
    #endif

    return directLighting;
}

float3 IndirectLighting_Silk(float3 diffCol, float3 specCol, float3 worldPos, float3 N, float3 T, float3 B, float3 V, float roughness, float aniso)
{
    // SH
    half3 sh = SampleSH(N);
    half3 diffuseLighting = diffCol * sh;

    // LD IBL
    // 这里对Cube进行扭曲拉伸，参考Filament代码getReflectedVector
    float3 anisoDir = aniso > 0 ? B : T;
    float3 anisoTangent = cross(V, anisoDir);
    float3 anisoNormal = cross(anisoTangent, anisoDir);
    float3 bentNormal = normalize(lerp(N, anisoNormal, abs(aniso)));

    half3 reflectDir = reflect(-V, bentNormal);
    half3 specLD = GlossyEnvironmentReflection(reflectDir, worldPos, roughness, 1);

    // DFG
    float NoV = saturate(abs(dot(bentNormal, V))+1e-5);
    half3 specDFG = EnvBRDFApprox(specCol, roughness, NoV);
    half3 specLighting = specLD * specDFG;

    float3 indirectLighting = diffuseLighting + specLighting;
    return indirectLighting;
}

float3 PBRLighting_Silk(float3 diffCol, float3 specCol, float3 worldPos, float3 N, float3 T, float3 B, float roughness, float aniso)
{
    float3 V = GetWorldSpaceNormalizeViewDir(worldPos);
    float3 lighting = float3(0,0,0);
    lighting += AllDirectLighting_Silk(diffCol, specCol, worldPos, N, T, B, V, roughness, aniso);
    lighting += IndirectLighting_Silk(diffCol, specCol, worldPos, N, T, B, V, roughness, aniso);
    return lighting;
}
