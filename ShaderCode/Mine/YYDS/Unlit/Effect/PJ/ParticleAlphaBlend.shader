Shader "TA/Unlit/Particles/PJ Alpha Blended"
{
	Properties
	{
		_TintColor("Tint Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white" {}
		_ColorScale("Scale", Range(0,5)) = 1
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
			BindChannels
			{
				Bind "Color", color
				Bind "Vertex", vertex
				Bind "TexCoord", texcoord
			}

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			half4 _TintColor;
			TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
			float4 _MainTex_ST;
			float _ColorScale;
			
			struct appdata_t
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 clipPos : POSITION;
				half4 color : COLOR;
				float2 uv : TEXCOORD0;
			};
			

			v2f vert (appdata_t v)
			{
				v2f o;
				o.clipPos = TransformObjectToHClip(v.vertex.xyz);
				o.color = v.color;
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				half4 mainCol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
				half4 col;
				col.rgb = mainCol.rgb * i.color * _TintColor.rgb * _ColorScale;
				col.a = mainCol.a * _TintColor.a;
				return col;
			}
			ENDHLSL
		}
	}

	FallBack Off
}
