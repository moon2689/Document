#include "../../TALibrary/TACommon.hlsl"

half3 BRDF_HarfLambertLighting(Light light, half3 diffCol, half3 N, half3 V, inout half3 radiance, inout half halfLambert)
{
    half3 L = V;//light.direction;
    half halfLambertIntensity = 0.3;
    half NoL = dot(N, L) * (1 - halfLambertIntensity) + halfLambertIntensity;
    NoL = saturate(NoL);
    halfLambert = NoL;
    //radiance = NoL * light.color * light.shadowAttenuation * light.distanceAttenuation;
    radiance = NoL * light.shadowAttenuation * light.distanceAttenuation;
    return diffCol * radiance;
}

half3 BRDF_HarfLambertLighting_FixN(Light light, half3 diffCol, half3 N, half3 V, inout half3 radiance, inout half halfLambert)
{
    half3 L = light.direction;
    half halfLambertIntensity = 0.3;
    half NoL = abs(dot(N, L)) * (1 - halfLambertIntensity) + halfLambertIntensity; //这里修复法线错误问题
    halfLambert = NoL;
    //radiance = NoL * light.color * light.shadowAttenuation * light.distanceAttenuation;
    radiance = NoL * light.shadowAttenuation * light.distanceAttenuation;
    return diffCol * radiance;
}

half3 BRDF_StandardSpecularLighting(half3 specCol, half3 N, half3 V, half3 L, half NoV, half NoL, half roughness, half3 radiance)
{
    half3 H = normalize(L + V);
    half NoH = saturate(dot(N, H));
    half VoH = saturate(dot(V, H));
    half a2 = Pow4(roughness);
    half D = D_GGX_ue4(a2, NoH);
    half Vis = Vis_SmithJointApprox(a2, NoV, NoL);
    half3 F = F_Schlick_ue4(specCol, VoH);
    half3 brdf = D * Vis * F * PI * radiance;
    return max(0.01.xxx, brdf);
}

// 普通衣服
half3 DirectLighting_Standard(Light light, half3 diffCol, half3 specCol, float3 worldPos, half3 N, half3 V, half NoV, half roughness)
{
    half3 L = light.direction;
    half3 brdf = half3(0, 0, 0);
    half3 radiance;
    half NoL;
    
    // 漫反射
    half3 diffuseLighting = BRDF_HarfLambertLighting(light, diffCol, N, V, radiance, NoL);
    brdf += diffuseLighting;

    // 镜面反射
    half3 specLighting = BRDF_StandardSpecularLighting(specCol, N, V, L, NoV, NoL, roughness, radiance);
    brdf += specLighting;
    return brdf;

    /*
    half3 L = light.direction;
    half3 H = normalize(L + V);
    half NoH = saturate(dot(N, H));
    half NoL = dot(N, L) * 0.5 + 0.5;
    half VoH = saturate(dot(V, H));
    //half3 radiance = NoL * light.color * light.shadowAttenuation * light.distanceAttenuation;
    half3 radiance = NoL * light.shadowAttenuation * light.distanceAttenuation;
    half3 brdf = half3(0, 0, 0);

    // 漫反射
    half3 diffuseLighting = Diffuse_LambertNoPI(diffCol) * radiance;
    brdf += diffuseLighting;

    // 镜面反射
    half a2 = Pow4(roughness);
    half D = D_GGX_ue4(a2, NoH);
    half Vis = Vis_SmithJointApprox(a2, NoV, NoL);
    half3 F = F_Schlick_ue4(specCol, VoH);
    half3 specLighting = D * Vis * F * radiance * PI;
    brdf += specLighting;

    return brdf;
    */
}

half3 PBRLighting_Standard(half3 diffCol, half3 specCol, float3 worldPos, half3 N, half roughness)
{
    half3 V = GetWorldSpaceNormalizeViewDir(worldPos);
    Light mainLight = GetMainLight_ta(worldPos);

    half NoV = saturate(abs(dot(N, V))+1e-5);
    half3 lighting = half3(0, 0, 0);
    half3 directLighting = DirectLighting_Standard(mainLight, diffCol, specCol, worldPos, N, V, NoV, roughness);
    lighting += directLighting;
    half3 indirectLighting = IndirectLighting_Standard(diffCol, specCol, worldPos, N, V, NoV, roughness);
    lighting += indirectLighting;
    return lighting;
}

// 丝绸
float3 DirectLighting_Silk(Light light, float3 diffCol, float3 specCol, float3 worldPos, float3 N, float3 T, float3 B, float3 V, float NoV, float roughness, float aniso)
{
    float3 L = light.direction;
    float3 H = normalize(L + V);
    float NoH = saturate(dot(N, H));
    //float NoV = saturate(abs(dot(N, V)) + 1e-5);
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

float3 IndirectLighting_Silk(float3 diffCol, float3 specCol, float3 worldPos, float3 N, float3 T, float3 B, float3 V, float NoV, float roughness, float aniso, half ao)
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
    half3 specLD = GlossyEnvironmentReflection(reflectDir, worldPos, roughness, ao);

    // DFG
    half3 specDFG = EnvBRDFApprox(specCol, roughness, NoV);
    half3 specLighting = specLD * specDFG;

    float3 indirectLighting = diffuseLighting + specLighting;
    return indirectLighting;
}

half3 IndirectLighting_SilkCustom(half3 diffCol, half3 specCol, half3 N, float3 T, float3 B, half3 V, half NoV, half roughness, float aniso, TEXTURECUBE_PARAM(cube, sampl), half4 env_HDR)
{
     // SH
    half3 sh = SampleSH(N);
    half3 diffuseLighting = diffCol * sh;

    // LD IBL
    // LD IBL
    // 这里对Cube进行扭曲拉伸，参考Filament代码getReflectedVector
    float3 anisoDir = aniso > 0 ? B : T;
    float3 anisoTangent = cross(V, anisoDir);
    float3 anisoNormal = cross(anisoTangent, anisoDir);
    float3 bentNormal = normalize(lerp(N, anisoNormal, abs(aniso)));

    half3 reflectDir = reflect(-V, bentNormal);
    roughness = roughness * (1.7 - 0.7 * roughness);
    half mip = roughness * 6.0;
    half4 cubeColor = SAMPLE_TEXTURECUBE_LOD(cube, sampl, reflectDir, mip);
    half3 specLD = DecodeHDREnvironment(cubeColor, env_HDR);

    // DFG
    half3 specDFG = EnvBRDFApprox(specCol, roughness, NoV);
    half3 specLighting = specLD * specDFG;

    half3 envColor = diffuseLighting + specLighting;
    return envColor;
}

float3 PBRLighting_Silk(float3 diffCol, float3 specCol, float3 worldPos, float3 N, float3 T, float3 B, float roughness, float aniso, half ao)
{
    float3 V = GetWorldSpaceNormalizeViewDir(worldPos);
    float NoV = saturate(abs(dot(N, V)) + 1e-5);
    Light mainLight = GetMainLight_ta(worldPos);
    float3 lighting = float3(0,0,0);
    lighting += DirectLighting_Silk(mainLight, diffCol, specCol, worldPos, N, T, B, V, NoV, roughness, aniso) * ao;
    lighting += IndirectLighting_Silk(diffCol, specCol, worldPos, N, T, B, V, NoV, roughness, aniso, ao);
    return lighting;
}

// 棉麻
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

    // 漫反射
    float3 diffuseLighting = Diffuse_Lambert(diffCol) * radiance;

    // 镜面反射
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
    float3 V = GetWorldSpaceNormalizeViewDir(worldPos);
    Light mainLight = GetMainLight_ta(worldPos);
    float3 directLighting = DirectLighting_Cotton(mainLight, diffCol, sheenCol, worldNormal, worldPos, V, roughness, occlusion, sheenRoughness, sheenDFG);
    float3 indirectLighting = IndirectLighting_Cotton(diffCol, sheenCol, worldNormal, worldPos, V, roughness, occlusion, sheenDFG);
    //directLighting = float3(0,0,0);
    return directLighting + indirectLighting;
}

// 布林布林高光
float3 SpecularLighting_Flakes(float3 specCol, float3 N, float3 V, float3 L, half roughness)
{
    half a2 = Pow4(roughness);
    float3 H = normalize(L + V);
    float NoH = saturate(dot(N, H));
    float NoV = saturate(abs(dot(N, V)) + 1e-5);
    float NoL = saturate(dot(N, L));
    float VoH = saturate(dot(V, H));

    float3 newLightCol = specCol * PI;

    // 镜面反射
    float D = D_GGX_ue4(a2, NoH);
    float Vis = Vis_SmithJointApprox(a2, NoV, NoL);
    float3 F = F_Schlick_ue4(specCol, VoH);
    float3 specLighting = (D * Vis * F) * NoL * newLightCol;

    return specLighting;
}

// 头发高光
half3 SpecularLighting_Hair(half3 specCol, half shiftnoise, half3 B, half3 N, half3 V, half gloss, half NoL)
{
    shiftnoise = clamp(shiftnoise, -1, 1.33);
    float BoV = dot(B + N * shiftnoise, V);
    half3 specular = specCol * pow(abs(1 - BoV * BoV), gloss) * NoL;
    specular = clamp(specular, float3(0,0,0), half3(1.51,1.51,1.51));
    return specular;
}

// 头发高光
half3 SpecularLighting_HairWithNoise(half3 specCol, TEXTURE2D_PARAM(noiseTex, samplerNoise), half2 uv, half noiseOffset, half3 B, half3 N, half3 V, half NoL)
{
    half4 shiftMap = SAMPLE_TEXTURE2D(noiseTex, samplerNoise, uv);
    half shiftnoise = clamp(shiftMap.b + noiseOffset, -1, 1.33);

    float BoV = dot(B + N * shiftnoise, V);
    half3 specular = specCol * Pow64(1 - BoV * BoV) * NoL;
    specular = clamp(specular, float3(0,0,0), half3(1.51,1.51,1.51));
    return specular;
}

half3 IndirectLighting_Custom(half3 diffCol, half3 specCol, half3 N, half3 V, half NoV, half roughness, TEXTURECUBE_PARAM(cube, sampl), half4 env_HDR, half specDFGIntensity)
{
     // SH
    half3 sh = SampleSH(N);
    half3 diffuseLighting = diffCol * sh;

    // LD IBL
    half3 reflectDir = reflect(-V, N);
    roughness = roughness * (1.7 - 0.7 * roughness);
    half mip = roughness * 6.0;
    half4 cubeColor = SAMPLE_TEXTURECUBE_LOD(cube, sampl, reflectDir, mip);
    half3 specLD = DecodeHDREnvironment(cubeColor, env_HDR);

    // DFG
    half3 specDFG = EnvBRDFApprox(specCol, roughness, NoV);
    specDFG = lerp(specDFG, 1, specDFGIntensity);
    half3 specLighting = specLD * specDFG;

    half3 envColor = diffuseLighting + specLighting;
    return envColor;
}

// 此公式来源于：https://zhuanlan.zhihu.com/p/487204843
// HSV -> RGB
half3 HUEToRGB(half h)
{
    half3 color;
    half hTemp = h*6;
    color.r = abs(hTemp-3) - 1;
    color.g = 2 - abs(hTemp-2);
    color.b = 2 - abs(hTemp-4);
    color = saturate(color);
    return color;
}

// HSV -> RGB
half3 HSVToRGB(half3 hsv)
{
    half3 rgb = HUEToRGB(hsv.x);
    half3 color = ((rgb-1)*hsv.y + 1) * hsv.z;
    return color;
}

// 计算镭射颜色
half3 CalcLaserColor(half fresnel, half4 param)
{
    half hueValue = fresnel * param.x + param.y;
    half3 hsvValue = half3(hueValue, param.z, param.w);
    half3 color = HSVToRGB(hsvValue);
    color = Pow2(color);
    return color;
}

// 闪烁效果，param(平铺，视线，流动，强度)
half3 CalcFlakeColor(half3 flakeCol, TEXTURE2D_PARAM(noiseMap, sampler_noiseMap), half3 V, half2 uv, half4 param)
{
    half2 uv_flake = uv * param.xx;
    half4 flakeMap1 = SAMPLE_TEXTURE2D(noiseMap, sampler_noiseMap, uv_flake);
    uv_flake += (V.xy * param.y + _Time.xx * param.z) * 0.1;
    half4 flakeMap2 = SAMPLE_TEXTURE2D(noiseMap, sampler_noiseMap, uv_flake);
    half3 finalFlakeCol = flakeCol * flakeMap1.r * flakeMap2.r * param.w * 10;
    return finalFlakeCol;
}

// 闪烁效果，param(平铺，视线，流动，强度)
half3 CalcFlakeColorPow2(half3 flakeCol, TEXTURE2D_PARAM(noiseMap, sampler_noiseMap), half3 V, half2 uv, half4 param)
{
    half2 uv_flake = uv * param.xx;
    half4 flakeMap1 = SAMPLE_TEXTURE2D(noiseMap, sampler_noiseMap, uv_flake);
    uv_flake += (V.xy * param.y + _Time.xx * param.z) * 0.1;
    half4 flakeMap2 = SAMPLE_TEXTURE2D(noiseMap, sampler_noiseMap, uv_flake);
    half3 finalFlakeCol = flakeCol * Pow2(flakeMap1.r) * flakeMap2.r * param.w * 10;
    return finalFlakeCol;
}

// 闪烁效果，param(平铺，视线，流动，强度)
half3 CalcFlakeColorPow3(half3 flakeCol, TEXTURE2D_PARAM(noiseMap, sampler_noiseMap), half3 V, half2 uv, half4 param)
{
    half2 uv_flake = uv * param.xx;
    half4 flakeMap1 = SAMPLE_TEXTURE2D(noiseMap, sampler_noiseMap, uv_flake);
    uv_flake += (V.xy * param.y + _Time.xx * param.z) * 0.1;
    half4 flakeMap2 = SAMPLE_TEXTURE2D(noiseMap, sampler_noiseMap, uv_flake);
    half3 finalFlakeCol = flakeCol * Pow3(flakeMap1.r) * flakeMap2.r * param.w * 10;
    return finalFlakeCol;
}

// 闪烁效果，param(平铺，视线，流动，强度)
half3 CalcFlakeColorPow4(half3 flakeCol, TEXTURE2D_PARAM(noiseMap, sampler_noiseMap), half3 V, half2 uv, half4 param)
{
    half2 uv_flake = uv * param.xx;
    half4 flakeMap1 = SAMPLE_TEXTURE2D(noiseMap, sampler_noiseMap, uv_flake);
    uv_flake += (V.xy * param.y + _Time.xx * param.z) * 0.1;
    half4 flakeMap2 = SAMPLE_TEXTURE2D(noiseMap, sampler_noiseMap, uv_flake);
    half3 finalFlakeCol = flakeCol * Pow4(flakeMap1.r) * flakeMap2.r * param.w * 10;
    return finalFlakeCol;
}

// 闪烁效果，param(平铺，视线，流动，强度)
half3 CalcFlakeRandomColor(TEXTURE2D_PARAM(noiseMap, sampler_noiseMap), half3 V, half NoV, half2 uv, half4 flakeParam)
{
    half3 laserColor = CalcLaserColor(Pow2(NoV), half4(0.5, 0.5, 2, 1));
    return CalcFlakeColorPow3(laserColor, noiseMap, sampler_noiseMap, V, uv, flakeParam);
}

half3 Diffuse_FixN(half3 diffCol, half3 N, half3 L)
{
    half NoL = dot(N, L);
    half halfLambert = abs(NoL) * 0.5 + 0.5; //这里法线有错误
    half3 diffuseLighting = diffCol * halfLambert;
    return diffuseLighting;
}

half3 Diffuse_FixN(half3 diffCol, half3 N, half3 L, inout half halfLambert)
{
    half NoL = dot(N, L);
    halfLambert = abs(NoL) * 0.5 + 0.5; //这里法线有错误
    half3 diffuseLighting = diffCol * halfLambert;
    return diffuseLighting;
}