Shader "TA/Unlit/Transparent/Transparent Base"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white"{}
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"RenderPipeline" = "UniversalForward"
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			Lighting Off 
			ZWrite Off

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
			float4 _MainTex_ST;
			
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 clipPos : POSITION;
				float2 uv : TEXCOORD0;
			};
			

			v2f vert (appdata_t v)
			{
				v2f o;
				o.clipPos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				half4 mainCol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
				return mainCol;
			}
			ENDHLSL
		}
	}

	FallBack Off
}
