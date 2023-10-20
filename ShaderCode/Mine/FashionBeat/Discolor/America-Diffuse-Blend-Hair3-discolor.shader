Shader "America/Character/America-Diffuse-Blend-Hair3-discolor"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Ramp ("Toon Ramp (RGB)", 2D) = "gray" {}
		_RampRate ("Ramp Rate", float) = 1
		
		_Cutoff( "Cutoff", Range (0,1)) = 0.5
		
		_OverlyingColor("Overlying Color", Color) = (0.5, 0.5, 0.5, 1)
		_DiffuseRate ("Diffuse Rate", float) = 2

		_DyeTex ("Dye Tex", 2D) = "black" {}
		_DyeValue1 ("Dye Value 1", Vector) = (0, 1, 1, 0)
		_DyeValue2 ("Dye Value 2", Vector) = (0, 1, 1, 0)
		_DyeValue3 ("Dye Value 3", Vector) = (0, 1, 1, 0)
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
			sampler2D _Ramp;
			float _RampRate;
			float _Cutoff;
			fixed4 _OverlyingColor;
			float _DiffuseRate;

			sampler2D _DyeTex;
			float4 _DyeValue1;
			float4 _DyeValue2;
			float4 _DyeValue3;

			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;
				clip(albedo.a - _Cutoff);

				fixed3 worldLight = UnityWorldSpaceLightDir(i.worldPos);
				fixed3 diffuse = CalcDiffuse(albedo, worldLight, i.worldNormal, _Ramp, _RampRate);
				
				fixed4 col = fixed4(diffuse * _DiffuseRate, albedo.a);
				col.rgb = Overlay(col, _OverlyingColor);

				fixed4 dyeCol = tex2D(_DyeTex, i.uv);
				col = ComputeFinalDyeColor(col, dyeCol, _DyeValue1, _DyeValue2, _DyeValue3);		// 染色

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
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off

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
			
			sampler2D _DyeTex;
			float4 _DyeValue1;
			float4 _DyeValue2;
			float4 _DyeValue3;


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;
				clip(_Cutoff - albedo.a);

				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 diffuse = CalcDiffuse(albedo, worldLight, i.worldNormal, _Ramp, _RampRate);
				
				fixed4 col = fixed4(diffuse * 2, albedo.a);
				col.rgb = Overlay(col, _OverlyingColor);

				fixed4 dyeCol = tex2D(_DyeTex, i.uv);
				col = ComputeFinalDyeColor(col, dyeCol, _DyeValue1, _DyeValue2, _DyeValue3);		// 染色
				return col;
			}

			ENDCG
		}
		
		
	} 

	Fallback "Diffuse"
}
