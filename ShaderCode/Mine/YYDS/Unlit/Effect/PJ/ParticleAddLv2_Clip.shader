Shader "TA/Unlit/Particles/PJ Additive Lv2 Clip"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Main Texture", 2D) = "white" {}
        _ClipMinY ("Clip Min Y", Range(0, 1)) = 0
		_ClipMaxY ("Clip Max Y", Range(0, 1)) = 1
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent+400"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"RenderPipeline" = "UniversalForward"
		}

		Pass
		{
			Blend SrcAlpha One
			Cull Off
			Lighting Off
			ZWrite Off
			
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
			float4 _MainTex_ST;
			half4 _TintColor;
            float _ClipMaxY, _ClipMinY;
			
			struct appdata_t
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : POSITION;
				half4 color : COLOR;
				float2 uv : TEXCOORD0;
			};

			v2f vert (appdata_t v)
			{
				v2f o;
				o.pos = TransformObjectToHClip(v.vertex.xyz);
				o.color = v.color;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			half4 frag (v2f i) : COLOR
			{
				half4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
				half4 color = 2.0f * i.color * _TintColor * mainTex;

                half2 screenUV = GetNormalizedScreenSpaceUV(i.pos);
                if (screenUV.y > _ClipMaxY || screenUV.y < _ClipMinY)
                    color.a = 0;

				return color;
			}
			ENDHLSL
		}
	} 
	
	Fallback Off
}
