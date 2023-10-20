Shader "TA/Unlit/UI/UIRenderTexture"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white"{}
		_Rect("Rect", Vector) = (0, 1, 0, 1)
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderPipeline" = "UniversalForward"
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			ZWrite Off
			Lighting Off 

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
			half4 _Rect;
            CBUFFER_END
			
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				half4 color : COLOR;
			};

			struct v2f
			{
				float4 clipPos : POSITION;
				float2 uv : TEXCOORD0;
				half4 color : COLOR;
			};
			

			v2f vert (appdata_t v)
			{
				v2f o;
				o.clipPos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;
				o.color = v.color;
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				float2 uv = i.uv;
				half4 mainCol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
				mainCol.a = step(_Rect.x, uv.x) * step(uv.x, _Rect.y) * step(_Rect.z, uv.y) * step(uv.y, _Rect.w);
				return mainCol;
			}
			ENDHLSL
		}
	}

	FallBack Off
}
