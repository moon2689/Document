#ifndef HAIRINC
#define HAIRINC

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"

#include "../Common/TABRDF.hlsl"
#include "MarshnerLighting.hlsl"
#include "HairUE4.hlsl"

struct appdata
{
    float4 positionOS   : POSITION;
    float2 uv           : TEXCOORD0;
    float4 tangentOS    : TANGENT;
    float3 normalOS     : NORMAL;
};

struct v2f
{
    float4 positionCS   : SV_POSITION;
    float2 uv           : TEXCOORD0;
    float3 tangentWS    : TEXCOORD1;
    float3 bitangentWS  : TEXCOORD2; 
    float3 normal       : TEXCOORD3; 
    float3 positionWS   : TEXCOORD4;
    float3 postionOS    : TEXCOORD5;
    float3 normalOS     : TEXCOORD6;
    float4 screenPos    : TEXCOORD7;
};

#define PI 3.14159265358979323846
#define MinValue 0.00000000001
#define MaxThanZero(foo) max(foo,MinValue)

sampler2D _BaseColorTex,_AOTex,_NormalTex,_HairShiftTex;

float _HairShiftTexScale;

float _AlphaClip;

float4 _First_HairColor,_Second_HairColor;
float _First_ShiftTangent,_First_AnisotropicPowerValue,_First_AnisotropicPowerScale;
float _Second_ShiftTangent,_Second_AnisotropicPowerValue,_Second_AnisotropicPowerScale;

float _NormalScale;
float _Diffuse_Min,_Diffuse_Max;
float _SHLightingIntensty;
float4 _Tint;
float _ShadowIntensity;

float _BackLightLerp,_BackLightPow,_BackLightIntensity,_EnableBackLight;
float4 _BakcLightColor;
float _EnableSH;

//Marschner Specular Lighting
float _Eccentric,_BackLit,_Area;
float _Marschner1Smoothness,_Marschner1Intensity,_Marschner2Smoothness,_Marschner2Intensity;

float SchlickFresnel(float u)
{
    float m = clamp(1-u, 0, 1);
    float m2 = m*m;
    return m2*m2*m; // pow(m,5)
}

float3 Diffuse_Disney(float3 BaseColor, float Roughness,float NdotV,float NdotL,float LdotH)
{
    // Diffuse fresnel - go from 1 at normal incidence to .5 at grazing
    // and mix in diffuse retro-reflection based on roughness
    float FL = SchlickFresnel(NdotL), FV = SchlickFresnel(NdotV);
    float Fd90 = 0.5 + 2 * LdotH*LdotH * Roughness;
    float Fd = lerp(1.0, Fd90, FL) * lerp(1.0, Fd90, FV);
    return Fd * BaseColor / PI;
}

v2f HairVertex (appdata v)
{
    v2f o;
    o.positionCS = TransformObjectToHClip(v.positionOS);
    o.uv = v.uv;
    o.normal = TransformObjectToWorldNormal(v.normalOS);
    o.positionWS = mul(unity_ObjectToWorld,v.positionOS);
    o.postionOS = v.positionOS.xyz;
    o.tangentWS = TransformObjectToWorldNormal(v.tangentOS);
    o.bitangentWS = cross(o.normal,o.tangentWS) * v.tangentOS.w;
    o.normalOS = v.normalOS;
    o.screenPos = ComputeScreenPos(o.positionCS);
    return o;
}

float SpecularKajiyaHair(float ShiftMap,float ShiftTangent,float PowerValue,float PowerScale,float3 N,float3 T,float3 H)
{
    float shift = ShiftMap + ShiftTangent;
    float3 T_Shift = normalize( T + N*shift);
    //因为 sin^2+cos^2 =1 所以 sin = sqrt(1-cos^2)
    float dotTH = dot(T_Shift,H);
    float sinTH = sqrt(1- dotTH*dotTH);  
    float dirAtten = smoothstep(-1,0,dotTH);
    float Specular = dirAtten * pow(sinTH,PowerValue)*PowerScale;
    return max(0,Specular);
}

float SimpleTransmission(float3 N,float3 L,float3 V,float TransLerp,float TransExp,float TransIntensity)
{
    float3 fakeN = -normalize(lerp(N,L,TransLerp));
    float trans = TransIntensity * pow( saturate( dot(fakeN,V)),TransExp);
    return trans;
}

//Face == ture : Front
//Face == false : Back

 float4 HairFragment (v2f input , bool Face : SV_IsFrontFace)
// float4 HairFragment (in v2f input )
{
    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    Light mainLight = GetMainLight(shadowCoord);
    float Shadow = lerp(_ShadowIntensity,1,mainLight.shadowAttenuation);
   
    //================== Texture SetUp  ============================================== //
    float2 uv = input.uv;
    float4 BaseMap = tex2D(_BaseColorTex,uv);
    BaseMap.rgb*=_Tint.rgb;
    
    clip(BaseMap.a -_AlphaClip);
    
    #ifdef SHADOW_CASTER
         // return 0;
    #endif
    
    // float4 AO = tex2D(_AOTex,uv);
    float4 HairShift = tex2D(_HairShiftTex,uv*_HairShiftTexScale);

//================== Variable  ============================================== //
    float3 T = normalize(input.tangentWS);
    float3 MeshNormal = normalize(input.normal);
    float3 N = normalize(input.normal);
     // if(!Face) N = -N;
    float3 B = normalize( cross(N,T));
    // float3 B = normalize( i.bitangent);
   
    float3 L =  normalize(_MainLightPosition.xyz);
    float3 V = normalize(_WorldSpaceCameraPos - input.positionWS);
    float3 H = normalize(V+L);

//================== Normal Map  ============================================== //
    float3 NormalMap = UnpackNormalScale(tex2D(_NormalTex,uv),_NormalScale);
    float3x3 TBN = float3x3(T,B,N);
    N = normalize( mul (NormalMap,TBN));
    
    // float HV = dot(H,V);
    // float NV = dot(N,V);
    float NL = saturate(dot(N,L));
    // float HL = dot(H,L);
    
//================== Kajiya  高光============================================== //
    float4 FinalColor =0;
    float3 KajiyaSpecular1  = _First_HairColor*0.1  * SpecularKajiyaHair(HairShift.r,_First_ShiftTangent,_First_AnisotropicPowerValue*100,_First_AnisotropicPowerScale, N,B,H);
    float3 KajiyaSpecular2 = _Second_HairColor*0.1 *  SpecularKajiyaHair(HairShift.r,_Second_ShiftTangent,_Second_AnisotropicPowerValue*100,_Second_AnisotropicPowerScale, N,B,H);
    float3 KajiyaSpecular = max(KajiyaSpecular1 , KajiyaSpecular2);
    // return float4(KajiyaSpecular,1);
    KajiyaSpecular = KajiyaSpecular*NL*mainLight.shadowAttenuation;

//================== Marschner  高光============================================== //
    // float3 MarschnerSpecular1 = _Marschner1Intensity * HairSpecularMarschner(BaseColor.rgb, L, V, N, 0,  _Marschner1Smoothness);
    // float3 MarschnerSpecular2 = _Marschner2Intensity* HairSpecularMarschner(BaseColor.rgb, L, V, N, 0,  _Marschner2Smoothness);
        
    float3 MarschnerSpecular1 = _Marschner1Intensity * HairSpecularMarschner(BaseMap.rgb,L, V, MeshNormal, _BackLit, _Area,1-_Marschner1Smoothness,_Eccentric);
    float3 MarschnerSpecular2 = _Marschner2Intensity * HairSpecularMarschner(BaseMap.rgb,L, V, N, _BackLit, _Area,1-_Marschner2Smoothness,_Eccentric);
    float3 MarschnerSpecular = max(MarschnerSpecular1,MarschnerSpecular2);
    MarschnerSpecular = mainLight.shadowAttenuation*MarschnerSpecular;
    
    float3 AdditionLight = AdditionalLights(BaseMap.rgb,N, V,_Marschner1Intensity,0,_Marschner1Smoothness,input.positionWS,_Marschner2Smoothness,_Marschner2Intensity);
    // float3 Diffuse = HairDiffuseWrapLight(BaseColor,L,V,N,0)*Shadow;//*mainLight.shadowAttenuation;
    float3 Diffuse = HairDiffuse(BaseMap,L,V,N,1,1);//*mainLight.shadowAttenuation;

    float DiffuseIntensity = 1;
///////////////////////// //模拟透射现象/////////////////////////////////////////
    float3 BackLight =0;
    UNITY_BRANCH if(_EnableBackLight)
        BackLight = _BakcLightColor* BackLighting(L, V, N, 1, _BackLightLerp, _BackLightPow, _BackLightIntensity,mainLight.color.rgb);
    
    //==================Final   ============================================== //
    #ifdef ENABLE_MARSCHNER_ON
        float3 Specular = (MarschnerSpecular+AdditionLight)* mainLight.shadowAttenuation;
        // float3 Specular =MarschnerSpecular1;
    #else
        float3 Specular = (KajiyaSpecular);
    #endif

    #ifdef ENABLE_SH_ON
        Diffuse += SampleSH(N)*BaseMap.rgb;
    #endif

    FinalColor.rgb = Diffuse + Specular+ BackLight;

//==================Alpha ============================================== //

    // return float4(BackLight,Alpha);
    // return  float4(FinalColor.rgb,0.2);
    // return float4(AdditionLight.rgb,Alpha);
    // return float4(AdditionLight.rgb,Alpha);
    // return float4(saturate(MarschnerSpecular),Alpha);
    // return float4(Diffuse.rgb,Alpha);
    // return BaseColor;
    // return  float4( SampleSH(float4(N,1)).rgb,BaseColor.a);
    return  float4(FinalColor.rgb,BaseMap.a);
}

//MRT multi render target
struct DepthPeelingOutput
{
    float4 color : SV_TARGET0;
    float depth : SV_TARGET1;
};

sampler2D _MaxDepthTex;
sampler2D _CameraDepthTexture;
int _DepthPeelingPassCount;

DepthPeelingOutput DepthPeelingPixel(v2f input, bool Face : SV_IsFrontFace)
{
    DepthPeelingOutput output;
    output.color = HairFragment(input,  Face);
    output.depth = input.positionCS.z;
    //第0次Draw 直接画颜色与深度
    UNITY_BRANCH if (_DepthPeelingPassCount==0)
        return output;
    
    float2 screenUV = input.screenPos /= input.screenPos.w;
    //上一帧的深度
    float lastDepth = tex2D(_MaxDepthTex,screenUV).r;
    //当前像素的深度
    float pixelDepth = input.positionCS.z;
    //如果当前像素离相机更近，那么丢弃该像素
    //DX离相机越近值越大 1->0 
    if(pixelDepth >= lastDepth) discard;
    
    // float OpaqueDepth = tex2D(_CameraDepthTexture,screenUV);
    // if(pixelDepth>OpaqueDepth) discard;
	            
    return output;
}

float4 ShaderCasterFragment(v2f input):SV_TARGET
{
    // return 0;
    return HairFragment(input,false);
}

float4 HairOpaqueFragment(v2f input, bool Face : SV_IsFrontFace):SV_TARGET
{
    // return 0;
    return HairFragment(input,Face);
}

#endif