Shader "America/Character/America-Diffuse-Specular-Shining-discolor"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Ramp ("Toon Ramp (RGB)", 2D) = "gray" {}
		_RampRate ("Ramp Rate", float) = 1
		_Cutoff( "Cutoff", Range (0,1)) = 0.5
		
		_OverlyingColor("Overlying Color", Color) = (0.5, 0.5, 0.5, 1)

		_SpecularGloss ("Specular Gloss", float) = 8
		_SpecularMask ("Specular Mask(RGB)", 2D) = "white" {}
		_DiffuseRate ("Diffuse Rate", float) = 1
		_SpecularRate ("Specular Rate", float) = 0.3
		
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_NoiseSize("Noise Size", Float) = 2
		_ShiningSpeed("Shining Speed", Float) = 0.1
		_SparkleColor("sparkle Color", Color) = (1,1,1,1)
		SparklePower("sparkle Power", Float) = 10
		
		_RimColor("Rim Color", Color) = (0.17,0.36,0.81,0.0)
		_RimPower("Rim Power", Range(0.6,36.0)) = 8.0
		_RimIntensity("Rim Intensity", Range(0.0,100.0)) = 1.0
		
		_rimsparkleRate("Rim sparkle Rate", Float) = 10

		_HeightFactor("Height Scale", Range(-1, 1)) = 0.05

		_DyeTex("Dye Tex", 2D) = "black" {}
		_DyeValue1("Dye Value 1", Vector) = (0, 1, 1, 0)
		_DyeValue2("Dye Value 2", Vector) = (0, 1, 1, 0)
		_DyeValue3("Dye Value 3", Vector) = (0, 1, 1, 0)
	}

	SubShader
	{
		Tags 
		{
			"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
			"Queue" = "Transparent+100"
		}
		LOD 200

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			
			#include "../AmericaCG.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			sampler2D _Ramp;
			float _RampRate;
			float _Cutoff;
			fixed4 _OverlyingColor;
			float _SpecularGloss;
			sampler2D _SpecularMask;
			float _DiffuseRate;
			float _SpecularRate;
			
			sampler2D _NoiseTex;
			float4 _Tint, _ShadowColor, _RimColor, _SparkleColor;
			float _NoiseSize, _ShiningSpeed;
			float _RimPower, _RimIntensity, _rimsparkleRate, SparklePower;
			float _HeightFactor;
			
			sampler2D _DyeTex;
			float4 _DyeValue1;
			float4 _DyeValue2;
			float4 _DyeValue3;


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				
				float3 lightDir_tangent : TEXCOORD3;
				float3 viewDir_tangent : TEXCOORD4;
			};

			// caculate parallax uv offset
			inline float2 CaculateParallaxUV(v2f i, float heightMulti)
			{
				//normalize view Dir
				float3 viewDir = normalize(i.lightDir_tangent);
				//偏移值 = 切线空间的视线方向.xy（uv空间下的视线方向）* height * 控制系数
				float2 offset = i.lightDir_tangent.xy * _HeightFactor * heightMulti;
				return offset;
			}
	
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				TANGENT_SPACE_ROTATION;
				o.lightDir_tangent = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)));
				o.viewDir_tangent = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)));
		
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;
				clip(albedo.a - _Cutoff);

				// diffuse
				fixed3 worldLight = UnityWorldSpaceLightDir(i.worldPos);
				fixed3 diffuse = CalcDiffuse(albedo, worldLight, i.worldNormal, _Ramp, _RampRate);
				
				// spec
				fixed3 worldView = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldView + worldLight);
				float specD = abs(dot(halfDir, i.worldNormal));
				fixed4 specMask = tex2D(_SpecularMask, i.uv);
				fixed3 specular = _LightColor0.rgb * pow(specD, _SpecularGloss) * specMask.rgb;

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
				
				// Rim
				float rim = 1.0 - max(0, dot(i.worldNormal, worldView));
				fixed3 rimCol = _RimColor.rgb * pow(rim, _RimPower) * _RimIntensity;

				// final color
				fixed3 sparkleCol1 = sparkle1 *  lerp(_SparkleColor, fixed3(1,1,1), 0.5);
				fixed3 sparkleCol2 = sparkle2 * _SparkleColor;
				fixed3 sparkleCol3 = sparkle3 * 0.5 * _SparkleColor;
				fixed3 sparkCol = (sparkleCol1 + sparkleCol2 + sparkleCol3 + 1) * rimCol * _rimsparkleRate;
				
				fixed4 col = fixed4(diffuse * _DiffuseRate + specular * _SpecularRate  + sparkCol, albedo.a);
				col.rgb = Overlay(col, _OverlyingColor);
				
				// dye color
				fixed4 dyeCol = tex2D(_DyeTex, i.uv);
				col = ComputeFinalDyeColor(col, dyeCol, _DyeValue1, _DyeValue2, _DyeValue3);

				return col;
			}

			ENDCG
		}
		
	} 

	Fallback "Diffuse"
}
