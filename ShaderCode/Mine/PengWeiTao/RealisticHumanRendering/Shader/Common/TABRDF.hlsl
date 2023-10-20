#ifndef TABRDF
#define TABRDF

#ifndef PI
    #define PI 3.141592654
#endif

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"

//D
float D_DistributionGGX(float3 N, float3 H, float Roughness)
{
    float a = Roughness * Roughness;
    // float a             = Roughness;
    float a2 = a * a;
    float NH = max(dot(N, H), 0);
    float NH2 = NH * NH;
    float nominator = a2;
    float denominator = (NH2 * (a2 - 1.0) + 1.0);
    denominator = PI * denominator * denominator;

    return nominator / max(denominator, 0.0000001); //防止分母为0
    // return              nominator/ (denominator) ;//防止分母为0
}

//G
float GeometrySchlickGGX(float NV, float Roughness)
{
    float r = Roughness + 1.0;
    float k = r * r / 8.0;
    float nominator = NV;
    float denominator = k + (1.0 - k) * NV;
    // return nominator/ max(denominator,0.001) ;//防止分母为0
    return nominator / max(denominator, 0.0000001); //防止分母为0
}

float G_GeometrySmith(float3 N, float3 V, float3 L, float Roughness)
{
    float NV = max(dot(N, V), 0);
    float NL = max(dot(N, L), 0);

    float ggx1 = GeometrySchlickGGX(NV, Roughness);
    float ggx2 = GeometrySchlickGGX(NL, Roughness);
    
    return ggx1 * ggx2;
}

//F
float3 F_FrenelSchlick(float NV, float3 F0)
{
    return F0 + (1.0 - F0) * pow(1.0 - NV, 5);
}

float3 FresnelSchlickRoughness(float NV, float3 F0, float Roughness)
{
    return F0 + (max(float3(1.0 - Roughness, 1.0 - Roughness, 1.0 - Roughness), F0) - F0) * pow(1.0 - NV, 5.0);
}

//UE4 Black Ops II modify version
float2 EnvBRDFApprox(float Roughness, float NoV)
{
    // [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
    // Adaptation to fit our G term.
    const float4 c0 = {-1, -0.0275, -0.572, 0.022};
    const float4 c1 = {1, 0.0425, 1.04, -0.04};
    float4 r = Roughness * c0 + c1;
    float a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y;
    float2 AB = float2(-1.04, 1.04) * a004 + r.zw;
    return AB;
}

float3 Specular_GGX(float3 N, float3 L, float3 H, float3 V, float NV, float NL, float HV, float Roughness, float3 F0)
{
    float D = D_DistributionGGX(N, H, Roughness);
    float3 F = F_FrenelSchlick(NV, F0);
    float G = G_GeometrySmith(N, V, L, Roughness);
    float3 nominator = D * F * G;
    float denominator = max(4 * NV * NL, 0.001);
    float3 Specular = nominator / denominator;
    Specular = max(Specular, 0);
    return Specular;
}

float3 Specular_GGX(float3 N, float3 L, float3 V,float Roughness, float3 F0)
{
    float3 H = normalize(V + L);
    float HV = saturate(dot(H, V));
    float NV = saturate(dot(N, V));
    float NL = saturate(dot(N, L));
    return Specular_GGX( N, L, H, V, NV, NL, HV, Roughness, F0);

    /*
    float D = D_DistributionGGX(N, H, Roughness);
    float3 F = F_FrenelSchlick(HV, F0);
    float G = G_GeometrySmith(N, V, L, Roughness);
    float3 nominator = D * F * G;
    float denominator = max(4 * NV * NL, 0.001);
    float3 Specular = nominator / denominator;
    Specular = max(Specular, 0);
    return Specular;
    */
    
}

float3 Specular_GGX_Skin(float3 N, float3 L,float3 V,float Roughness, float3 F0=float3(0.04,0.04,0.04))
{
    float3 H = normalize(V + L);
    // float HV = saturate(dot(H, V));
    float NV = saturate(dot(N, V));
    // float NL = saturate(dot(N, L));
    
    float D = D_DistributionGGX(N, H, Roughness);
    float3 F = F_FrenelSchlick(NV, F0);
    float G = G_GeometrySmith(N, V, L, Roughness);
    // float3 nominator = D * F * G;
    // float denominator = max(4 * NV * NL, 0.001);
    // float3 Specular = nominator / denominator;
    // Specular = max(Specular, 0);
    // return denominator;
    return D*F*G * 0.25;
    // return Specular;
}

// Black Ops II
// float2 EnvBRDFApprox(float Roughness, float NV)
// {
//     float g = 1 -Roughness;
//     float4 t = float4(1/0.96, 0.475, (0.0275 - 0.25*0.04)/0.96, 0.25);
//     t *= float4(g, g, g, g);
//     t += float4(0, 0, (0.015 - 0.75*0.04)/0.96, 0.75);
//     float A = t.x * min(t.y, exp2(-9.28 * NV)) + t.z;
//     float B = t.w;
//     return float2 ( t.w-A,A);
// }如果

float3 ACESToneMapping(float3 x)
{
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
}

float4 ACESToneMapping(float4 x)
{
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
}

#ifndef UNITY_SPECCUBE_LOD_STEPS
    #define UNITY_SPECCUBE_LOD_STEPS 6
#endif


float3 SpecularIndirect(float3 N, float3 V, float Roughness, float3 F0)
{
    //Specular
    float3 R = reflect(-V, N);
    float NV = dot(N, V);
    float3 F_IndirectLight = FresnelSchlickRoughness(NV, F0, Roughness);
    // return F_IndirectLight.xyzz;
    // float3 F_IndirectLight = F_FrenelSchlick(NV,F0);
    float mip = Roughness * (1.7 - 0.7 * Roughness) * UNITY_SPECCUBE_LOD_STEPS;
    float4 rgb_mip = unity_SpecCube0.SampleLevel(samplerunity_SpecCube0,R,mip);
    
    //间接光镜面反射采样的预过滤环境贴图
    #if defined(UNITY_USE_NATIVE_HDR)
        float3 EnvSpecularPrefilted = encodedIrradiance.rgb;
    #else
        float3 EnvSpecularPrefilted = DecodeHDREnvironment(rgb_mip, unity_SpecCube0_HDR);
    #endif // UNITY_USE_NATIVE_HDR

    //LUT采样
    // float2 env_brdf = tex2D(_BRDFLUTTex, float2(NV, Roughness)).rg; //0.356
    // float2 env_brdf = tex2D(_BRDFLUTTex, float2(lerp(0, 0.99, NV), lerp(0, 0.99, Roughness))).rg;

    //数值近似
    float2 env_brdf = EnvBRDFApprox(Roughness, NV);
    float3 Specular_Indirect = EnvSpecularPrefilted * (F_IndirectLight * env_brdf.r + env_brdf.g);
    return Specular_Indirect;
}

float Diffuse_Disney(float roughness, float NoV, float NoL, float LoH) 
{
    // Burley 2012, "Physically-Based Shading at Disney"
    float f90 = 0.5 + 2.0 * roughness * LoH * LoH;
    float lightScatter = F_Schlick(1.0, f90, NoL);
    float viewScatter  = F_Schlick(1.0, f90, NoV);
    return lightScatter * viewScatter * (1.0 / PI);
}

float3 Erot(float3 p, float3 ax,float angle)
{
    return lerp(dot(ax, p) * ax, p,cos(angle)) + cross(ax, p) * sin(angle);
}

float3 GetAdditionDiffuseLights(float3 N,float3 positionWS)
{
    float3 color = 0;
    int pixelLightCount = GetAdditionalLightsCount();
    uint meshRenderingLayers = GetMeshRenderingLightLayer();
    for (int i = 0; i < pixelLightCount; ++i)
    {
        Light light = GetAdditionalLight(i, positionWS);

        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        {
            float attenuation = light.distanceAttenuation * light.shadowAttenuation;
            float3 attenuatedLightColor = light.color * attenuation;
            float3 Diffuse = saturate(dot(N,light.direction))*attenuatedLightColor;
            color += Diffuse;
        }
    }
    return color;
}

float3 GetAdditionSoecularLights(float3 N,float3 V,float3 positionWS,float Roughness)
{
    float3 color = 0;
    int pixelLightCount = GetAdditionalLightsCount();
    for (int i = 0; i < pixelLightCount; ++i)
    {
        Light light = GetAdditionalLight(i, positionWS);
        float attenuation = light.distanceAttenuation * light.shadowAttenuation;
        float3 attenuatedLightColor = light.color * attenuation;
        float3 Specular = Specular_GGX_Skin(N,light.direction,V,Roughness)*attenuatedLightColor;
        color += Specular;
    }
    return color;
}

#endif