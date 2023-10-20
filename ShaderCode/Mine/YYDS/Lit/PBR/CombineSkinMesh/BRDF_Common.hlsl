#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "../../../Library/PBRBRDF.hlsl"

float2 RotateAroundByRadian(float radian, float2 target)
{
    float cosRad = cos(radian);
    float sinRad = sin(radian);
    target = float2(target.x * cosRad + target.y * sinRad, target.y * cosRad - target.x * sinRad);
    return target;
}

float2 RotateAroundByDegree(float degree, float2 target)
{
    float radian = degree * PI / 180;
    return RotateAroundByRadian(radian, target);
}

float3 RotateAroundByRadian(float radian, float3 target)
{
    float cosRad = cos(radian);
    float sinRad = sin(radian);
    float2x2 matrixRotate = float2x2(cosRad, -sinRad, sinRad, cosRad);
    float2 dirRotate = mul(matrixRotate, target.xz);
    target = float3(dirRotate.x, target.y, dirRotate.y);
    return target;
}

float3 RotateAroundByDegree(float degree, float3 target)
{
    float radian = degree * PI / 180;
    return RotateAroundByRadian(radian, target);
}

Light GetMainLight_ta(float3 worldPos)
{
    half4 shadowMask = CalculateShadowMask_unity();
    float4 shadowCoord = CalculateShadowCoord_unity(worldPos);
    Light mainLight = GetMainLight(shadowCoord, worldPos, shadowMask);
    return mainLight;
}

half3 IndirectLighting_Custom(half3 diffCol, half3 specCol, half3 N, half3 V, half NoV, half roughness, TEXTURECUBE_PARAM(cube, sampl), half4 env_HDR)
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
    half3 specLighting = specLD * specDFG;

    half3 envColor = diffuseLighting + specLighting;
    return envColor;
}

// 漫反射 兰伯特
half3 Lambert_Diffuse(Light light, half3 diffCol, half3 N)
{
    half3 L = light.direction;
    half NoL = saturate(dot(N, L));
    half3 diffuseLighting = diffCol * NoL;
    return diffuseLighting;
}

// 漫反射 半兰伯特
half3 HalfLambert_Diffuse(Light light, half3 diffCol, half3 N, half3 V)
{
    half3 L = V;//light.direction;
    half NoL = dot(N, L);
    half halfLambert = NoL * 0.5 + 0.5;
    half3 diffuseLighting = diffCol * halfLambert;
    return diffuseLighting;
}

half3 HalfLambert_Diffuse(Light light, half3 diffCol, half3 N, half3 V, inout half halfLambert)
{
    half3 L = V;//light.direction;
    half NoL = dot(N, L);
    halfLambert = NoL * 0.5 + 0.5;
    half3 diffuseLighting = diffCol * halfLambert;
    return diffuseLighting;
}

// 高光 Blinn Phong
half3 BlinnPhong_Specular(half3 specCol, half3 N, half3 L, half3 V, half specShininess)
{
    half3 H = normalize(L + V);
    half NoH = dot(N, H);
    half specTerm = max(0.0001, pow(abs(NoH), specShininess));
    return specTerm * specCol;
}

// 高光 Phong
half3 Phong_Specular(half3 specCol, half3 N, half3 L, half3 V, half specShininess)
{
    half3 reflectDir = reflect(-L, N);
    half VoR = dot(reflectDir, V);
    half specTerm = max(0.0001, pow(abs(VoR), specShininess));
    return specTerm * specCol;
}

// 菲涅尔
half3 CalcFresnelColor(half3 fresnelCol, half NoV)
{
    half temp = 1 - NoV;
    temp = Pow2(temp);
    return fresnelCol * temp;
}

half Pow32(half x)
{
    x = abs(x);
    half x2 = x * x;
    half x4 = x2 * x2;
    half x8 = x4 * x4;
    half x16 = x8 * x8;
    half x32 = x16 * x16;
    return x32;
}

half Pow64(half x)
{
    half x32 = Pow32(x);
    return x32 * x32;
}