#ifndef MARSHNER_LIGHTING
#define MARSHNER_LIGHTING

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"

#define MAX_TRANSLUNCENCY  5
#define MAX_REFLECTION 22
#define PIc 3.1415926
#define SQRT2PI 2.50663
#define Pow2(v) (v*v)


float3 BackLighting(float3 lightDirection, float3 viewDir, float3 worldNormal, float attenuation,
                   float distortion, float power, float scale, float3 subsurfaceColor)
{
    float3 H = normalize(lightDirection + worldNormal * distortion);
    float I = pow(saturate(dot(viewDir, -H)), power) * scale;
    return subsurfaceColor * 5 * I * attenuation;
}

inline float square(float x)
{
    return x * x;
}

inline float Hair_G(float B, float Theta)
{
    return exp(-0.5 * square(Theta) / (B * B)) / (SQRT2PI * B);
}

float HairIOF(float Eccentric)
{
    float n = 1.55;
    float a = 1 - Eccentric;
    float ior1 = 2 * (n - 1) * (a * a) - n + 2;
    float ior2 = 2 * (n - 1) / (a * a) - n + 2;
    return 0.5f * ((ior1 + ior2) + 0.5f * (ior1 - ior2));
}

inline float3 SpecularFresnel(float3 F0, float vDotH)
{
    return F0 + (1.0f - F0) * pow(1 - vDotH, 5);
}

float3 DiffuseLight(float3 Albedo, float3 L, float3 N)
{
    float DiffuseScatter = (1.0 / PIc) * saturate(dot(N, L));
    return Albedo * DiffuseScatter;
}

const float AlphaArray[] = {
    - 0.0998,
    0.0499f,
    0.1996
};

float3 HairSpecularMarschner(float3 Albedo, float3 L, float3 V, float3 N, float Area, float smoothness)
{
    float3 S = 0;

    const float VoL = dot(V, L);
    const float SinThetaL = dot(N, L);
    const float SinThetaV = dot(N, V);
    float cosThetaL = sqrt(max(0, 1 - SinThetaL * SinThetaL));
    float cosThetaV = sqrt(max(0, 1 - SinThetaV * SinThetaV));
    float CosThetaD = sqrt((1 + cosThetaL * cosThetaV + SinThetaV * SinThetaL) / 2.0);

    const float3 Lp = L - SinThetaL * N;
    const float3 Vp = V - SinThetaV * N;
    const float CosPhi = dot(Lp, Vp) * rsqrt(dot(Lp, Lp) * dot(Vp, Vp) + 1e-4);
    const float CosfloatPhi = sqrt(saturate(0.5 + 0.5 * CosPhi));


    float B[] = {
        Area + square(1 - smoothness),
        Area + square(1 - smoothness) / 2,
        Area + square(1 - smoothness * 2)
    };

    float hairIOF = HairIOF(0);
    float F0 = square((1 - hairIOF) / (1 + hairIOF));

    float3 Tp;
    float Mp, Np, Fp, f;
    float ThetaH = SinThetaL + SinThetaV;
    // R
    Mp = Hair_G(B[0], ThetaH - AlphaArray[0]);
    Np = 0.25 * CosfloatPhi;
    Fp = SpecularFresnel(F0, sqrt(saturate(0.5 + 0.5 * VoL)));
    S += (Mp * Np) * (Fp * lerp(1, 0, saturate(-VoL)));

    // TRT
    Mp = Hair_G(B[2], ThetaH - AlphaArray[2]);
    f = SpecularFresnel(F0, CosThetaD * 0.5f);
    Fp = square(1 - f) * f;
    Tp = pow(Albedo, 0.8 / CosThetaD);
    Np = exp(17 * CosPhi - 16.78);

    S += (Mp * Np) * (Fp * Tp);

    return S;
}

float3 HairDiffuseWrapLight(float3 BaseColor, float3 L, float3 V, half3 N, half Shadow)
{
    float3 S = 0;
    float KajiyaDiffuse = 1 - abs(dot(N, L));

    float3 FakeNormal = normalize(V - N * dot(V, N));
    N = FakeNormal;

    // Hack approximation for multiple scattering.
    float Wrap = 1;
    float NoL = saturate((dot(N, L) + Wrap) / square(1 + Wrap));
    float DiffuseScatter = (1 / PI) * lerp(NoL, KajiyaDiffuse, 0.33);// *s.Metallic;
    float Luma = Luminance(BaseColor);
    float3 ScatterTint = pow(BaseColor / Luma, 1 - Shadow);
    S = sqrt(BaseColor) * DiffuseScatter * ScatterTint;
    return max(S,0);
}

float HairLum(float3 rgb)
{
    return dot(rgb, float3(0.0396819152, 0.458021790, 0.00609653955));
}

float3 HairDiffuse(float3 BaseColor, float3 L, float3 V, half3 N, float Shadow,float DiffuseIntensity)
{
    // Use soft Kajiya Kay diffuse attenuation
    float KajiyaDiffuse = 1 - abs(dot(N, L));

    float3 FakeNormal = normalize(V - N * dot(V, N));
    //N = normalize( DiffuseN + FakeNormal * 2 );
    N = FakeNormal;

    //Wrap Lighting
    // Hack approximation for multiple scattering.
    float Wrap = 1;
    float NoL = saturate((dot(N, L) + Wrap) / Pow2(1 + Wrap));
    float DiffuseScatter = (1 / PI) * lerp(NoL, KajiyaDiffuse, 0.33) * DiffuseIntensity;
    float Luma = HairLum(BaseColor);
    float3 ScatterTint = pow(abs(BaseColor / Luma), 1 - Shadow);
    return sqrt(abs(BaseColor)) * DiffuseScatter * ScatterTint;
}

// Reference: A Practical and Controllable Hair and Fur Model for Production Path Tracing.
float3 ColorToAbsorption(float3 C, float B = 0.3f)
{
    const float b2 = B * B;
    const float b3 = B * b2;
    const float b4 = b2 * b2;
    const float b5 = B * b4;
    const float D = (5.969f - 0.215f * B + 2.532f * b2 - 10.73f * b3 + 5.574f * b4 + 0.245f * b5);
    return Pow2(log(C) / D);
}

float3 HairSpecularMarschner(float3 BaseColor,float3 L, float3 V, half3 N, float Backlit, float Area,float Roughness,float Eccentric)
{
    float3 S = 0;

    const float VoL = dot(V, L);
    const float SinThetaL = dot(N, L);
    const float SinThetaV = dot(N, V);
    float cosThetaL = sqrt(max(0, 1 - SinThetaL * SinThetaL));
    float cosThetaV = sqrt(max(0, 1 - SinThetaV * SinThetaV));
    float CosThetaD = sqrt((1 + cosThetaL * cosThetaV + SinThetaV * SinThetaL) / 2.0);

    const float3 Lp = L - SinThetaL * N;
    const float3 Vp = V - SinThetaV * N;
    const float CosPhi = dot(Lp, Vp) * rsqrt(dot(Lp, Lp) * dot(Vp, Vp) + 1e-4);
    const float CosHalfPhi = sqrt(saturate(0.5 + 0.5 * CosPhi));

    float n_prime = 1.19 / CosThetaD + 0.36 * CosThetaD;

    float Shift = 0.0499f;
    float Alpha[] =
    {
        -0.0998,//-Shift * 2,
        0.0499f,// Shift,
        0.1996  // Shift * 4
    };
    float B[] =
    {
        Area + square(Roughness),
        Area + square(Roughness) / 2,
        Area + square(Roughness) * 2
    };

    float hairIOF = HairIOF(Eccentric);
    float F0 = square((1 - hairIOF) / (1 + hairIOF));

    float3 Tp;
    float Mp, Np, Fp, a, h, f;
    float ThetaH = SinThetaL + SinThetaV;
    // R
    Mp = Hair_G(B[0], ThetaH - Alpha[0]);
    Np = 0.25 * CosHalfPhi;
    Fp = SpecularFresnel(F0, sqrt(saturate(0.5 + 0.5 * VoL)));
    S += (Mp * Np) * (Fp * lerp(1, Backlit, saturate(-VoL)));

    // TT
    Mp = Hair_G(B[1], ThetaH - Alpha[1]);
    a = (1.55f / hairIOF) * rcp(n_prime);
    h = CosHalfPhi * (1 + a * (0.6 - 0.8 * CosPhi));
    f = SpecularFresnel(F0, CosThetaD * sqrt(saturate(1 - h * h)));
    Fp = square(1 - f);
    float3 AbsorptionColor = ColorToAbsorption(BaseColor);
    Tp = exp(-AbsorptionColor * 2 * abs(1 - Pow2(h * a) / CosThetaD));
    // Tp = pow(BaseColor, 0.5 * sqrt(1 - square((h * a))) / CosThetaD);
    Np = exp(-3.65 * CosPhi - 3.98);
    S += (Mp * Np) * (Fp * Tp) * Backlit;

    // TRT
    Mp = Hair_G(B[2], ThetaH - Alpha[2]);
    f = SpecularFresnel(F0, CosThetaD * 0.5f);
    Fp = square(1 - f) * f;
    Tp = pow(BaseColor, 0.8 / CosThetaD);
    Np = exp(17 * CosPhi - 16.78);

    S += (Mp * Np) * (Fp * Tp);

    return S;
}

float3 HairBxDF(float3 Albedo, float3 N, float3 V, float3 L, float Shadow, float reflectionArea, float smoothness)
{
    return DiffuseLight(Albedo, L, N) + HairSpecularMarschner(Albedo, L, V, N, reflectionArea,
                                                              clamp(smoothness, 0, 0.99)) * Shadow;
}

void URPLighting_float(float3 BaseColor,float3 worldNormal, float3 viewDirection, float3 lightDirection, float attenuation,
                       float4 SpecularColor, float specularIntensity, float reflectionArea, float smoothness,
                       out float4 Color)
{
    float3 marshnerLighting = SpecularColor * MAX_REFLECTION * specularIntensity *
        HairBxDF(
            BaseColor,
            worldNormal,
            viewDirection,
            - lightDirection,
            attenuation,
            reflectionArea,
            smoothness
        );
    Color = float4(marshnerLighting, 1);
}

void URPBackLighting_float(float3 lightDirection, float3 viewDir, float3 worldNormal, float attenuation,
                           float distortion, float power, float scale, float4 subsurfaceColor, out float4 Color)
{
    Color = 1;
    Color.xyz = BackLighting(lightDirection, viewDir, worldNormal, attenuation, distortion, power, scale,
                             subsurfaceColor);
}

float4 AdditionalLights(float3 BaseColor,float3 worldNormal, float3 viewDirection,
                       float specularIntensity, float reflectionArea, float smoothness,
                       float3 worldPosition, float smoothness2, float specularIntensity2)
{
    worldNormal = normalize(worldNormal);
    viewDirection = normalize(viewDirection);
    int pixelLightCount = GetAdditionalLightsCount();
    float4 color = 0;
    uint meshRenderingLayers = GetMeshRenderingLightLayer();
    for (int i = 0; i < pixelLightCount; ++i)
    {
        Light light = GetAdditionalLight(i, worldPosition);
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        {
            float attenuation = light.distanceAttenuation * light.shadowAttenuation;
            float3 attenuatedLightColor = light.color * attenuation;

            float4 c = 0;
            URPLighting_float(BaseColor,worldNormal, viewDirection, light.direction, attenuation,
                              float4(attenuatedLightColor, 1), specularIntensity, reflectionArea, smoothness, c);
            color += c;
            URPLighting_float(BaseColor,worldNormal, viewDirection, light.direction, attenuation,
                              float4(attenuatedLightColor, 1), specularIntensity2, reflectionArea, smoothness2, c);
            color += c;
        }
    }
    return color;
}

#endif
