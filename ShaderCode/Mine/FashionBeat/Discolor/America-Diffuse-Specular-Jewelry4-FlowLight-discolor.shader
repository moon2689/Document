﻿Shader "America/Character/America-Diffuse-Specular-Jewelry4-FlowLight-discolor"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_Ramp ("Toon Ramp (RGB)", 2D) = "gray" {}
		_RampRate ("Ramp Rate", float) = 1
		_Cutoff( "Cutoff", Range (0,1)) = 0.5
		
		_OverlyingColor("Overlying Color", Color) = (0.5, 0.5, 0.5, 1)

		_SpecularGloss ("Specular Gloss", float) = 8
		_SpecularMask ("Specular Mask(RGB)", 2D) = "white" {}
		_DiffuseRate ("Diffuse Rate", float) = 2
		_SpecularRate ("Specular Rate", float) = 2

		_Cubemap("Cubemap", Cube) = "" {}
        _ReflectionAmount("Reflection Amount", Range(0, 1)) = 0.5
		
		_FlowLightTex ("Flow Light (RGB)", 2D) = "black" {}
		_FlowLightMask ("Flow Light Mask (RGB)", 2D) = "white" {}
		_FlowLightNoise ("Flow Light Noise (RGB)", 2D) = "white" {}
		_FlowLightColor ("Flow Light Color", Color) = (1,1,1,1)
		_FlowSpeed ("Flow Speed", Vector) = (1, 0, 0, 0)

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
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

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
			sampler2D _NormalMap;
			sampler2D _Ramp;
			float _RampRate;
			float _Cutoff;
			fixed4 _OverlyingColor;
			float _SpecularGloss;
			sampler2D _SpecularMask;
			float _DiffuseRate;
			float _SpecularRate;
			
            samplerCUBE _Cubemap;
            float _ReflectionAmount;

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
				float4 T2W1 : TEXCOORD1;
                float4 T2W2 : TEXCOORD2;
                float4 T2W3 : TEXCOORD3;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 binormal = cross(normalize(worldNormal), normalize(worldTangent)) * v.tangent.w;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.T2W1 = float4(worldTangent.x, binormal.x, worldNormal.x, worldPos.x);
                o.T2W2 = float4(worldTangent.y, binormal.y, worldNormal.y, worldPos.y);
                o.T2W3 = float4(worldTangent.z, binormal.z, worldNormal.z, worldPos.z);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{				
				float3 worldPos = float3(i.T2W1.w, i.T2W2.w, i.T2W3.w);
                float3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
                float3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				float3 tangentNormal = UnpackNormal(tex2D(_NormalMap, i.uv));
                float3x3 tanToWorld = float3x3(i.T2W1.xyz, i.T2W2.xyz, i.T2W3.xyz);
                float3 worldNormal = mul(tanToWorld, tangentNormal);
				
				fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;
				clip(albedo.a - _Cutoff);

				// diffuse
				fixed3 diffuse = CalcDiffuse(albedo, worldLight, worldNormal, _Ramp, _RampRate);
				
				// spec
				fixed3 halfDir = normalize(worldView + worldLight);
				float specD = abs(dot(halfDir, worldNormal));
				fixed4 specMask = tex2D(_SpecularMask, i.uv);
				fixed3 specular = _LightColor0.rgb * pow(specD, _SpecularGloss) * specMask.rgb;

				// reflect
				float3 refDir = reflect(-worldView, worldNormal);
                fixed3 refCol = texCUBE(_Cubemap, refDir);
				diffuse = lerp(diffuse * _DiffuseRate, refCol, _ReflectionAmount);

				fixed4 col = fixed4(diffuse + specular * _SpecularRate, albedo.a);
				col.rgb = Overlay(col, _OverlyingColor);

				// dye color
				fixed4 dyeCol = tex2D(_DyeTex, i.uv);
				col = ComputeFinalDyeColor(col, dyeCol, _DyeValue1, _DyeValue2, _DyeValue3);

				return col;
			}

			ENDCG
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}
			Blend SrcAlpha OneMinusSrcAlpha, One One
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			sampler2D _FlowLightTex;
			sampler2D _FlowLightMask;
			sampler2D _FlowLightNoise;
			fixed4 _FlowLightColor;
			float4 _FlowSpeed;
			float4 _FlowLightNoise_ST;
			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				float2 uvNoise = v.uv * _FlowLightNoise_ST.xy + _Time.yy * _FlowSpeed.xy;
				o.uv = float4(v.uv, uvNoise);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed4 albedo = tex2D(_FlowLightTex, i.uv);				

				// flow light
				fixed4 maskTex = tex2D(_FlowLightMask, i.uv.xy);
				fixed4 noiseTex = tex2D(_FlowLightNoise, i.uv.zw);
				fixed3 flowCol = _FlowLightColor * maskTex.r * noiseTex.rgb;

				fixed4 col;
				col.rgb = albedo.rgb + flowCol;
				col.a = albedo.a;
				return col;
			}
			
			ENDCG
		}
		
	} 

	Fallback "Diffuse"
}
