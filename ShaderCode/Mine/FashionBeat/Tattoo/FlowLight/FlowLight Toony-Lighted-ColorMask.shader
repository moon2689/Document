﻿Shader "America/Character/Tattoo/NewEffect/FlowLight/FlowLight Toony-Lighted-ColorMask"
{
	Properties
	{
		_Color ("Main Color", Color) = (0.682345,0.682345,0.682345,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_DiffuseRate ("Diffuse Rate", float) = 2
		_Ramp ("Toon Ramp (RGB)", 2D) = "gray" {}
		_RampRate ("Ramp Rate", float) = 1
		_Cutoff("Cutoff", Range (0,1)) = 0.5

		_FlowLightMask ("Flow Light Mask (RGB)", 2D) = "white" {}
		_FlowLightNoise ("Flow Light Noise (RGB)", 2D) = "white" {}
		_FlowLightColor ("Flow Light Color", Color) = (1,1,1,1)
		_FlowSpeed ("Flow Speed", Vector) = (1, 0, 0, 0)
		
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
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			#include "../../AmericaCG.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			sampler2D _NormalMap;
			float _DiffuseRate;
			sampler2D _Ramp;
			float _RampRate;
			float _Cutoff;

			sampler2D _FlowLightMask;
			sampler2D _FlowLightNoise;
			fixed4 _FlowLightColor;
			float4 _FlowSpeed;
			float4 _FlowLightNoise_ST;
			
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
				float4 uv : TEXCOORD0;
				float4 T2W1 : TEXCOORD1;
                float4 T2W2 : TEXCOORD2;
                float4 T2W3 : TEXCOORD3;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				float2 uvNoise = v.uv * _FlowLightNoise_ST.xy + _Time.yy * _FlowSpeed.xy;
				o.uv = float4(v.uv, uvNoise);
				
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
				
				fixed4 ct = tex2D(_MainTex, i.uv);

				clip(ct.a - _Cutoff);

				// 纹身
				ct = ApplyTattoo(i.uv, _TattooTex1, _TattooPos1, ct);
				ct = ApplyTattoo(i.uv, _TattooTex2, _TattooPos2, ct);
				ct = ApplyTattoo(i.uv, _TattooTex3, _TattooPos3, ct);
				ct = ApplyTattoo(i.uv, _TattooTex4, _TattooPos4, ct);

				clip(ct.a - _Cutoff);
				
				fixed3 emission = ((1 - ct.a) * ct.rgb ) * _Color;
				
				fixed4 albedo;
				albedo.rgb = ((1 - ct.a) * ct.rgb ) * _Color + ct.a * ct.rgb;
				albedo.a = ct.a;

				// diff
				fixed3 diffuse = CalcDiffuse(albedo, worldLight, worldNormal, _Ramp, _RampRate);
				
				// flow light
				fixed4 maskTex = tex2D(_FlowLightMask, i.uv.xy);
				fixed4 noiseTex = tex2D(_FlowLightNoise, i.uv.zw);
				fixed3 flowCol = _FlowLightColor * maskTex.r * noiseTex.rgb;

				fixed4 col = fixed4(emission + diffuse * _DiffuseRate + flowCol, ct.a);

				return col;
			}

			ENDCG
		}

	} 

	Fallback "Diffuse"
}
