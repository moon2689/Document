﻿Shader "America/Character/Tattoo/NewEffect/Toony-Lighted-Cutoff"
{
	Properties
	{
		_Color ("Main Color", Color) = (0.5,0.5,0.5,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_DiffuseRate ("Diffuse Rate", float) = 2
		_Ramp ("Toon Ramp (RGB)", 2D) = "gray" {}
		_RampRate ("Ramp Rate", float) = 1
		_AlphaTex ("Alpha (RGB)", 2D) = "white" {}
		_Cutoff( "Cutoff", Range (0,1)) = 0.5
		
		_OverlyingColor("Overlying Color", Color) = (0.5, 0.5, 0.5, 1)

		_TattooTex1 ("Tattoo 1 (RGBA)", 2D) = "black" {}
		_TattooPos1 ("Tattoo Position 1", Vector) = (0,0,1,1)
		_TattooTex2 ("Tattoo 2 (RGBA)", 2D) = "black" {}
		_TattooPos2 ("Tattoo Position 2", Vector) = (0,0,1,1)
		_TattooTex3 ("Tattoo 3 (RGBA)", 2D) = "black" {}
		_TattooPos3 ("Tattoo Position 3", Vector) = (0,0,1,1)
		_TattooTex4 ("Tattoo 4 (RGBA)", 2D) = "black" {}
		_TattooPos4 ("Tattoo Position 4", Vector) = (0,0,1,1)
	}

	SubShader 
	{
		Tags
		{
			"Queue" = "Transparent+100"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		LOD 200		

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}
			Cull off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			#include "../AmericaCG.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NormalMap;
			float _DiffuseRate;
			sampler2D _Ramp;
			float _RampRate;
			sampler2D _AlphaTex;
			float _Cutoff;
			fixed4 _OverlyingColor;
			
			sampler2D _TattooTex1;
			float4 _TattooPos1;
			sampler2D _TattooTex2;
			float4 _TattooPos2;
			sampler2D _TattooTex3;
			float4 _TattooPos3;
			sampler2D _TattooTex4;
			float4 _TattooPos4;

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
				o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
				
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
                //float3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				float3 tangentNormal = UnpackNormal(tex2D(_NormalMap, i.uv));
                float3x3 tanToWorld = float3x3(i.T2W1.xyz, i.T2W2.xyz, i.T2W3.xyz);
                float3 worldNormal = mul(tanToWorld, tangentNormal);
				
				half4 c = tex2D(_MainTex, i.uv);

				// 纹身
				c = ApplyTattoo(i.uv, _TattooTex1, _TattooPos1, c);
				c = ApplyTattoo(i.uv, _TattooTex2, _TattooPos2, c);
				c = ApplyTattoo(i.uv, _TattooTex3, _TattooPos3, c);
				c = ApplyTattoo(i.uv, _TattooTex4, _TattooPos4, c);

				c *= _Color;

				fixed4 a = tex2D(_AlphaTex, i.uv);

				clip( a.r - _Cutoff );

				fixed4 albedo = c;

				float d = dot(worldLight, worldNormal) * 0.5 +0.5;
				fixed3 rampCol = tex2D(_Ramp, float2(d, d)).rgb;
				fixed3 diffuse = CalcDiffuse(albedo, worldLight, worldNormal, _Ramp, _RampRate);
				
				fixed4 col = fixed4(diffuse * _DiffuseRate, a.r);
				col.rgb = Overlay(col, _OverlyingColor);

				return col;
			}

			ENDCG
		}

	} 

	Fallback "Diffuse"
}
