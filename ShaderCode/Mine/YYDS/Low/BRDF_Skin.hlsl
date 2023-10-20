#include "../../TALibrary/TACommon.hlsl"

half3 DirectorLighting_HeadDress(Light light, half3 diffCol, half3 specCol, half3 N, half3 L, half3 V, half NoV, half roughness)
{
    half3 H = normalize(L + V);
    half NoH = saturate(dot(N, H));
    half NoL = saturate(dot(N, L));
    NoL = NoL * 0.5 + 0.5;
    half VoH = saturate(dot(V, H));
    //half3 radiance = NoL * light.color * light.shadowAttenuation * light.distanceAttenuation * PI;
    half3 radiance = NoL * light.shadowAttenuation * light.distanceAttenuation * PI;
    half3 brdf = half3(0, 0, 0);

    // 漫反射
    half3 diffLighting = diffCol * NoL;
    brdf += diffLighting;

    // 镜面反射
    half a2 = Pow4(roughness);
    half D = D_GGX_ue4(a2, NoH);
    half Vis = Vis_SmithJointApprox(a2, NoV, NoL);
    half3 F = F_Schlick_ue4(specCol, VoH);
    half3 specLighting = D * Vis * F * radiance;
    brdf += specLighting;

    return brdf;
}

// 高光 Blinn Phong
half3 BlinnPhong_SpecularSkin(half3 specCol, half3 N, half3 L, half3 V)
{
    half3 H = normalize(L + V);
    half NoH = dot(N, H);
    half specTerm = max(0.0001, Pow32(NoH));
    return specTerm * specCol;
}

half3 IndirectLighting_Skin(half3 diffCol, half3 N)
{
    // SH
    half3 sh = SampleSH(N);
    half3 diffuseLighting = diffCol * sh;
    return diffuseLighting;
}

half2 ScaleUVsByCenter(half2 uv, float scale)
{
    float2 center = float2(0.5, 0.5);
    return (uv - center) / scale + center;
}

half2 GetEyeParallaxUVOffset(float2 originUV, half eyeballScale, half3 V, float3x3 TBN, half parallaxValue)
{
    //视察偏移
    half centerDistance = distance(originUV, float2(0.5, 0.5));
    half depth = smoothstep(eyeballScale * 0.5, 0, centerDistance);
    half3 tangentV = normalize(mul(TBN, V));
    half2 offset = depth * tangentV.xy * parallaxValue;
    return offset;
}

half2 GetEyeballUV(float2 originUV, half eyeballScale, half3 V, float3x3 TBN, half parallaxValue)
{
    half2 uv_eyeballMap = ScaleUVsByCenter(originUV, eyeballScale);
    half2 parallaxOffset = GetEyeParallaxUVOffset(originUV, eyeballScale, V, TBN, parallaxValue); //视察偏移
    uv_eyeballMap -= parallaxOffset;
    return uv_eyeballMap;
}