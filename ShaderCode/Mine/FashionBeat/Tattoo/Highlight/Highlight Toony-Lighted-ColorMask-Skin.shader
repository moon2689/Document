Shader "America/Character/Tattoo/NewEffect/Highlight/Highlight Toony-Lighted-ColorMask-Skin"
{
	Properties
	{
		_Color ("Main Color", Color) = (0.5,0.5,0.5,1)
		_ClothColor("Cloth Color", Color) = (0.5,0.5,0.5,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_MainTexMask ("Mask (RGB)", 2D) = "white" {}
		_Ramp ("Toon Ramp (RGB)", 2D) = "gray" {}
		_RampRate ("Ramp Rate", float) = 1
		_Cutoff( "Cutoff", Range (0,1)) = 0.5

		_OverlyingColor("Overlying Color", Color) = (0.5, 0.5, 0.5, 1)
		
		_SpecularGloss ("Specular Gloss", float) = 8
		_SpecularMask ("Specular Mask(RGB)", 2D) = "white" {}
		_DiffuseRate ("Diffuse Rate", float) = 2
		_SpecularRate ("Specular Rate", float) = 2
		
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
			fixed4 _ClothColor;
			sampler2D _MainTex;
			sampler2D _NormalMap;
			sampler2D _MainTexMask;
			sampler2D _Ramp;
			float _RampRate;
			float _Cutoff;

			fixed4 _OverlyingColor;
			float _SpecularGloss;
			sampler2D _SpecularMask;
			float _DiffuseRate;
			float _SpecularRate;
			
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
				
				fixed4 ct = tex2D(_MainTex, i.uv);
				fixed4 mask = tex2D(_MainTexMask, i.uv);
				bool isSkin = mask.r < 0.1;

				// 纹身
				if(isSkin)
				{
					// 纹身
					ct = ApplyTattoo(i.uv, _TattooTex1, _TattooPos1, ct);
					ct = ApplyTattoo(i.uv, _TattooTex2, _TattooPos2, ct);
					ct = ApplyTattoo(i.uv, _TattooTex3, _TattooPos3, ct);
					ct = ApplyTattoo(i.uv, _TattooTex4, _TattooPos4, ct);
				}
				
				fixed ca = mask.rgb;
				
				fixed4 albedo;
				albedo.rgb = ((1 - ca) * ct.rgb ) * _Color + ca * ct.rgb * _ClothColor;
				albedo.a = ct.a;
				
				clip ( albedo.a - _Cutoff );

				

				// diff
				fixed3 diffuse = CalcDiffuse(albedo, worldLight, worldNormal, _Ramp, _RampRate);
				
				// spec
				fixed3 halfDir = normalize(worldView + worldLight);
				float specD = abs(dot(halfDir, worldNormal));
				fixed4 specMask = tex2D(_SpecularMask, i.uv);
				fixed3 specular = _LightColor0.rgb * pow(specD, _SpecularGloss) * specMask.rgb;

				fixed4 col = fixed4(diffuse * _DiffuseRate + specular * _SpecularRate, ct.a);
				col.rgb = Overlay(col, _OverlyingColor);
				
				return col;
			}

			ENDCG
		}

	} 

	Fallback "Diffuse"
}
