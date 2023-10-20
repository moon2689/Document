/*
PBR光照模型：
Lighting = BRDF * NdotL * LightColor;
主流：BRDF = kD / PI + kS * D * V * F;
Unity变种: unity_BRDF = kD + kS * D * V * F * PI;
遵循能量守恒原则，即 kD + kS <= 1

直接光照公式：
DirectLighting = (DiffuseColor / PI + D(roughness, x) * V(roughness, x) * F(SpecularColor, x)) * NdotL * LightColor;
其中 V = G / (4 * NdotL * NdotV)
各参数含义：
DiffuseColor 漫反射颜色
SpecularColor 镜面反射颜色
D项 法线分布函数
V项 可见性项
G项 几何函数
F项 菲涅尔方程
roughness 粗糙度

间接光照公式：
IndirectLighting = DiffuseColor / PI * SH + LD * DFG(SpecularColor);
各参数含义：
SH 球谐光照
LD 预过滤环境映射
DFG: Environment BRDF
*/
#include "PBRBRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

float3 DirectLighting_Standard(Light light, float3 diffCol, float3 specCol, float3 worldNormal, float3 worldPos, float3 viewDir, float a2, float occlusion)
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

    // 漫反射
    float3 diffuseLighting = Diffuse_Lambert(diffCol);

    // 镜面反射
    float D = D_GGX_ue4(a2, NoH);
    float Vis = Vis_SmithJointApprox(a2, NoV, NoL);
    float3 F = F_Schlick_ue4(specCol, VoH);
    float3 specLighting = D * Vis * F;

    float3 lighting = (diffuseLighting + specLighting) * radiance;
    return lighting;
}

float3 AllDirectLighting_Standard(float3 diffCol, float3 specCol, float3 worldNormal, float3 worldPos, float3 viewDir, float roughness, float occlusion)
{
    float a2 = Pow4(roughness);
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
    Light mainLight = GetMainLight(shadowCoord);

    float3 directLighting = DirectLighting_Standard(mainLight, diffCol, specCol, worldNormal, worldPos, viewDir, a2, occlusion);

    #ifdef _ADDITIONAL_LIGHTS
        uint addLightCount = GetAdditionalLightsCount();
        for(uint lightIndex = 0; lightIndex < addLightCount; ++lightIndex)
        {
            Light addLight = GetAdditionalLight(lightIndex, worldPos);
            directLighting += DirectLighting_Standard(addLight, diffCol, specCol, worldNormal, worldPos, viewDir, a2, occlusion);
        }
    #endif

    return directLighting;
}

float3 IndirectLighting_Standard(float3 diffCol, float3 specCol, float3 worldNormal, float3 worldPos, float3 viewDir, float roughness, float occlusion)
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

    // DFG
    half3 specDFG = EnvBRDFApprox(specCol, roughness, NoV);
    half3 specLighting = specLD * specDFG;

    float3 indirectLighting = diffuseLighting + specLighting;
    return indirectLighting;
}

float3 PBRLighting_Standard(float3 diffCol, float3 specCol, float3 worldNormal, float3 worldPos, float roughness, float occlusion)
{
    float3 viewDir = GetWorldSpaceNormalizeViewDir(worldPos);
    float3 directLighting = AllDirectLighting_Standard(diffCol, specCol, worldNormal, worldPos, viewDir, roughness, occlusion);
    float3 indirectLighting = IndirectLighting_Standard(diffCol, specCol, worldNormal, worldPos, viewDir, roughness, occlusion);
    return directLighting + indirectLighting;
}