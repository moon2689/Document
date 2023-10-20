#ifndef SKINSSSS
#define SKINSSSS

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 uv : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 normalWS : TEXCOORD2;
    float3 tangentWS : TEXCOORD3;
    float3 bitangentWS : TEXCOORD4;
    float4 screenPos : TEXCOORD5;
};

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"

#include "../Common/TABRDF.hlsl"
#include "Beckman.hlsl"

float4 _DetailNormalMap_ST;
float _DetailNormalMapInteisty;
TEXTURE2D(_SSSBlurRT);
SAMPLER(sampler_SSSBlurRT);

TEXTURE2D(_RoughnessMap);SAMPLER(sampler_RoughnessMap);
float EnableRoughnessMap, _Roughness, _Roughness2;
float _EnableBaseMapEyeMask, _RoughnessEye, _SpecIntensityEye;


float _BeckmanRoughness, _BeckmanIntensity;

Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    output.positionCS = TransformObjectToHClip(input.positionOS);
    output.tangentWS.xyz = normalInput.tangentWS;
    output.bitangentWS = normalInput.bitangentWS;
    output.normalWS = normalInput.normalWS;
    output.positionWS = TransformObjectToWorld(input.positionOS);
    output.uv = frac( input.uv);
    output.screenPos = ComputeScreenPos(output.positionCS);
    return output;
}


float4 SkinSSSSFragment(Varyings input) : SV_Target
{
    float2 uv = input.uv;
    float3 L = normalize(_MainLightPosition.xyz);
    float3 V = normalize(_WorldSpaceCameraPos - input.positionWS);

    float3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv), _BumpScale);

    float2 detailUv = uv * _DetailNormalMap_ST.xy + _DetailNormalMap_ST.zw;
    half3 detailNormalTS = UnpackNormal(SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap, detailUv));
    detailNormalTS = normalize(detailNormalTS);
    normalTS = lerp(normalTS, BlendNormalRNM(normalTS, detailNormalTS), _DetailNormalMapInteisty);

    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);

    float3 N = normalize(TransformTangentToWorld(normalTS, tangentToWorld));

    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    Light mainLight = GetMainLight(shadowCoord);

    #ifdef SKIN_SSSS_DIFFUSE
        float NL = dot(N, L);
        float3 directDiffuse = saturate(NL) * mainLight.shadowAttenuation * mainLight.color;

        //==================多光源   ============================================== //
        float3 additionalDiffuse = GetAdditionDiffuseLights(N,input.positionWS);
        directDiffuse += additionalDiffuse;
    
        #ifdef DISABLE_SKIN_SH
            float3 DiffuseLighting = directDiffuse;
        #else
            float3 indirectDiffuse = SampleSH(N);
            float3 DiffuseLighting = (directDiffuse + indirectDiffuse);
        #endif
        
        return DiffuseLighting.xyzz;
    #endif

    #ifdef SKIN_SSSS_SPECULAR
        #ifdef ENABLE_ROUGHNESS_MAP_ON
            float Roughness = SAMPLE_TEXTURE2D(_RoughnessMap, sampler_RoughnessMap,uv).r;
        #else
            float Roughness = _Roughness;
        #endif

        float4 BaseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
        float3 Specular = 0;
        UNITY_BRANCH if (_EnableBaseMapEyeMask)
        {
            // Roughness = _RoughnessEye*BaseMap.a;
            Specular = BaseMap.a * _SpecIntensityEye * Specular_GGX(N, L, V, _RoughnessEye, (0.04).xxx) * mainLight.
                shadowAttenuation;
            // return Roughness;
        }

        #if !defined(ENABLE_BECKMAN_ON)
            float3 SpecularGGX1 = Specular_GGX_Skin(N, L, V, Roughness, (0.04).xxx) * mainLight.shadowAttenuation;
            float3 SpecularGGX2 = Specular_GGX_Skin(N, L, V, _Roughness2, (0.04).xxx) * mainLight.shadowAttenuation;
            Specular += max(SpecularGGX1, SpecularGGX2) * mainLight.color;
        #else
            float3 SpecularBeckman1 = Specular_Beckman_Skin(N,L,V,_BeckmanRoughness,_BeckmanIntensity*0.1);
            Specular += SpecularBeckman1* mainLight.color* mainLight.shadowAttenuation;
        #endif

        //采样SSSBlurRT
        float2 screenUV = input.screenPos.xy / input.screenPos.w;
        float4 SkinSSSMap = SAMPLE_TEXTURE2D(_SSSBlurRT, sampler_SSSBlurRT, screenUV);

        // float3 SkinSSS = BaseMap * pow(SkinSSSMap,0.45) + Specular.xyzz;
        float3 SkinSSS = _BaseColor.rgb * BaseMap * SkinSSSMap + Specular.xyzz;
        return SkinSSS.xyzz;
    #endif

    return 0;
}

float _SkinLutScale,_SkinSHInttensity;
TEXTURE2D(_SkinLut);SAMPLER(sampler_SkinLut);
TEXTURE2D(_SkinCurvatureMap);SAMPLER(sampler_SkinCurvatureMap);

float4 SkinSSSFragment(Varyings input) : SV_Target
{
    float2 uv = input.uv;
    float3 L = normalize(_MainLightPosition.xyz);
    float3 V = normalize(_WorldSpaceCameraPos - input.positionWS);
    float3 MeshNormal = normalize(input.normalWS);

//=========Normal Map=================================================================================== 
    float3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv), _BumpScale);
    float2 detailUv = uv * _DetailNormalMap_ST.xy + _DetailNormalMap_ST.zw;
    half3 detailNormalTS = UnpackNormal(SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap, detailUv));
    detailNormalTS = normalize(detailNormalTS);
    normalTS = lerp(normalTS, BlendNormalRNM(normalTS, detailNormalTS), _DetailNormalMapInteisty);

    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);

    float3 N = normalize(TransformTangentToWorld(normalTS, tangentToWorld));

//=========Shadow =================================================================================== 
    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    Light mainLight = GetMainLight(shadowCoord);

    float4 BaseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv)*_BaseColor;
    float3 Specular = 0;

//=========Skin SSS =================================================================================== 
    float NL = dot(N, L);
    float NL01 = NL*0.5+0.5;
    float MeshNL01 = saturate(dot(MeshNormal,L)*0.5+0.5);
    // float3 directDiffuse = saturate(NL) * mainLight.shadowAttenuation * mainLight.color;
    float CurvatureMap =  SAMPLE_TEXTURE2D(_SkinCurvatureMap, sampler_SkinCurvatureMap,input.uv);
    // float curvature = length(fwidth(input.positionWS))/length(fwidth(MeshNormal));
    float3 directLighting  = SAMPLE_TEXTURE2D(_SkinLut, sampler_SkinLut, float2(MeshNL01,_SkinLutScale*CurvatureMap));
    // return directLighting.xyzz;
    //==================多光源   ============================================== //
    float3 additionalDiffuse = GetAdditionDiffuseLights(N, input.positionWS);

    float3 indirectDiffuse = SampleSH(N)*BaseMap.rgb;

    float3 Diffuse  = directLighting*BaseMap.rgb* mainLight.shadowAttenuation * mainLight.color +  indirectDiffuse + additionalDiffuse*BaseMap.rgb;
     // return Diffuse.xyzz;

//=========Skin Specular =================================================================================== 

    #ifdef ENABLE_ROUGHNESS_MAP_ON
        float Roughness = SAMPLE_TEXTURE2D(_RoughnessMap, sampler_RoughnessMap,uv).r;
    #else
        float Roughness = _Roughness;
    #endif

    UNITY_BRANCH if (_EnableBaseMapEyeMask)
    {
        // Roughness = _RoughnessEye*BaseMap.a;
        Specular = BaseMap.a * _SpecIntensityEye * Specular_GGX(N, L, V, _RoughnessEye, (0.04).xxx) * mainLight.shadowAttenuation;
        // return Roughness;
    }

    #if !defined(ENABLE_BECKMAN_ON)
        float3 SpecularGGX1 = Specular_GGX_Skin(N, L, V, Roughness, (0.04).xxx) * mainLight.shadowAttenuation;
        float3 SpecularGGX2 = Specular_GGX_Skin(N, L, V, _Roughness2, (0.04).xxx) * mainLight.shadowAttenuation;
        Specular += max(SpecularGGX1, SpecularGGX2) * mainLight.color;
    #else
        float3 SpecularBeckman1 = Specular_Beckman_Skin(N,L,V,_BeckmanRoughness,_BeckmanIntensity*0.1);
        Specular += SpecularBeckman1* mainLight.color* mainLight.shadowAttenuation;
    #endif

    float3 SkinSSS = Diffuse + Specular.xyzz;
    return SkinSSS.xyzz;
}

// struct SkinMRT
// {
//     float4 Color;
//     float4 Depth;
// };
// SkinMRT SkinFragmentMRT(Varyings input)
// {
//     SkinMRT mrt = (SkinMRT)0;
//     mrt.Color = LitPassFragment(input);
//     mrt.Depth = input.positionCS.z;
//     return mrt;
// }

#endif
