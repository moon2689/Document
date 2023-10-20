Shader "WalkingFat/Sparkle/Sparkle01"
{
	Properties
	{
		_Tint("Tint", Color) = (0.5,0.5,0.5,1)
		_ShadowColor("Shadow Color", Color) = (0,0,0,1)

		_NoiseTex("Noise Texture", 2D) = "white" {}
	_NoiseSize("Noise Size", Float) = 2
		_ShiningSpeed("Shining Speed", Float) = 0.1
		_SparkleColor("sparkle Color", Color) = (1,1,1,1)
		SparklePower("sparkle Power", Float) = 10

		_Specular("Specular", Range(0,1)) = 0.5
		_Gloss("Gloss", Range(0,1)) = 0.5

		_RimColor("Rim Color", Color) = (0.17,0.36,0.81,0.0)
		_RimPower("Rim Power", Range(0.6,36.0)) = 8.0
		_RimIntensity("Rim Intensity", Range(0.0,100.0)) = 1.0

		_specsparkleRate("Specular sparkle Rate", Float) = 6
		_rimsparkleRate("Rim sparkle Rate", Float) = 10
		_diffsparkleRate("Diffuse sparkle Rate", Float) = 1

		_ParallaxMap("Parallax Map", 2D) = "white" {}
	_HeightFactor("Height Scale", Range(-1, 1)) = 0.05

	}

		SubShader
	{
		Tags
	{
		"RenderType" = "Opaque"
	}

		LOD 100

		Pass
	{
		Tags{ "LightMode" = "ForwardBase" }

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

#include "AutoLight.cginc"
#include "Lighting.cginc"
#pragma multi_compile_fwdbase
#pragma multi_compile_fwdadd_fullshadows
#pragma multi_compile_fog

		//#pragma glsl

		sampler2D _NoiseTex, _ParallaxMap;
	float4 _NoiseTex_ST, _ParallaxMap_ST;
	float4 _Tint, _ShadowColor, _RimColor, _SparkleColor;
	float _Specular, _Gloss, _NoiseSize, _ShiningSpeed;
	float _RimPower, _RimIntensity, _specsparkleRate, _rimsparkleRate, _diffsparkleRate, SparklePower;
	float _HeightFactor;

	struct appdata {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 uv : TEXCOORD0;
		float4 tangent : TANGENT;
	};

	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		float4 posWorld : TEXCOORD1;
		float3 normalDir : TEXCOORD2;
		float3 lightDir : TEXCOORD3;
		float3 viewDir : TEXCOORD4;
		float3 lightDir_tangent : TEXCOORD5;
		float3 viewDir_tangent : TEXCOORD6;
		LIGHTING_COORDS(7,8)
			UNITY_FOG_COORDS(9)
	};

	// caculate parallax uv offset
	inline float2 CaculateParallaxUV(v2f i, float heightMulti)
	{
		float height = tex2D(_ParallaxMap, i.uv).r;
		//normalize view Dir
		float3 viewDir = normalize(i.lightDir_tangent);
		//偏移值 = 切线空间的视线方向.xy（uv空间下的视线方向）* height * 控制系数
		float2 offset = i.lightDir_tangent.xy * height * _HeightFactor * heightMulti;
		return offset;
	}

	v2f vert(appdata v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.normalDir = UnityObjectToWorldNormal(v.normal);
		o.posWorld = mul(unity_ObjectToWorld, v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);

		o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.posWorld.xyz);
		o.lightDir = normalize(_WorldSpaceLightPos0.xyz);

		TANGENT_SPACE_ROTATION;
		o.lightDir_tangent = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)));
		o.viewDir_tangent = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)));

		UNITY_TRANSFER_FOG(o,o.pos);
		TRANSFER_VERTEX_TO_FRAGMENT(o)
			return o;
	}

	float4 frag(v2f i) : SV_Target
	{
		i.normalDir = normalize(i.normalDir);

	// attenuation
	float attenuation = LIGHT_ATTENUATION(i);
	float3 attenColor = attenuation * _LightColor0.xyz;

	// specular
	float specularPow = exp2((1 - _Gloss) * 10.0 + 1.0);
	float3 specularColor = float4 (_Specular,_Specular,_Specular,1);

	float3 halfVector = normalize(i.lightDir + i.viewDir);
	float3 directSpecular = pow(max(0,dot(halfVector, i.normalDir)), specularPow) * specularColor;
	float3 specular = directSpecular * attenColor;

	// sparkle
	float2 uvOffset = CaculateParallaxUV(i, 1);
	float noise1 = tex2D(_NoiseTex, i.uv * _NoiseSize + float2 (0, _Time.x * _ShiningSpeed) + uvOffset).r;
	float noise2 = tex2D(_NoiseTex, i.uv * _NoiseSize * 1.4 + float2 (_Time.x * _ShiningSpeed, 0)).r;
	float sparkle1 = pow(noise1 * noise2 * 2, SparklePower);

	uvOffset = CaculateParallaxUV(i, 2);
	noise1 = tex2D(_NoiseTex, i.uv * _NoiseSize + float2 (0.3, _Time.x * _ShiningSpeed) + uvOffset).r;
	noise2 = tex2D(_NoiseTex, i.uv * _NoiseSize * 1.4 + float2 (_Time.x * _ShiningSpeed, 0.3) + uvOffset).r;
	float sparkle2 = pow(noise1 * noise2 * 2, SparklePower);

	uvOffset = CaculateParallaxUV(i, 3);
	noise1 = tex2D(_NoiseTex, i.uv * _NoiseSize + float2 (0.6, _Time.x * _ShiningSpeed) + uvOffset).r;
	noise2 = tex2D(_NoiseTex, i.uv * _NoiseSize * 1.4 + float2 (_Time.x * _ShiningSpeed, 0.6) + uvOffset).r;
	float sparkle3 = pow(noise1 * noise2 * 2, SparklePower);

	// diffuse
	float NdotL = saturate(dot(i.normalDir, i.lightDir));
	float3 directDiffuse = NdotL * attenColor;
	float3 diffuseCol = lerp(_ShadowColor, _Tint, directDiffuse);

	// Rim
	float rim = 1.0 - max(0, dot(i.normalDir, i.viewDir));
	fixed3 rimCol = _RimColor.rgb * pow(rim, _RimPower) * _RimIntensity;

	// final color
	fixed3 sparkleCol1 = sparkle1 * (specular * _specsparkleRate + directDiffuse * _diffsparkleRate + rimCol * _rimsparkleRate) * lerp(_SparkleColor, fixed3(1,1,1), 0.5);
	fixed3 sparkleCol2 = sparkle2 * (specular * _specsparkleRate + directDiffuse * _diffsparkleRate + rimCol * _rimsparkleRate) * _SparkleColor;
	fixed3 sparkleCol3 = sparkle3 * (specular * _specsparkleRate + directDiffuse * _diffsparkleRate + rimCol * _rimsparkleRate) * 0.5 * _SparkleColor;

	fixed4 finalCol = fixed4(diffuseCol + specular + sparkleCol1 + sparkleCol2 + sparkleCol3 + rimCol, 1);

	UNITY_APPLY_FOG(i.fogCoord, finalCol);
	return finalCol;
	}
		ENDCG
	}
	}
		Fallback "VertexLit"
}