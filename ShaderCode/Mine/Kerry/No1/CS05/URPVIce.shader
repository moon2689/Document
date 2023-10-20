Shader "MyURP/Kerry/Unlit/URPVice"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Grow("Grow",Float) = 0.0
		_GrowMin("GrowMin",Float) = 0.6
		_GrowMax("GrowMax",Float) = 1.35
		_EndMin("End Min",Float) = 0.5
		_EndMax("End Max",Float) = 1.0
		_Expand("Expand",Float) = 0.0
		_Scale("Scale",Float) = 0.0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
			};

			TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
			float4 _MainTex_ST;
			float _Grow;
			float _GrowMin;
			float _GrowMax;
			float _EndMin;
			float _EndMax;
			float _Expand;
			float _Scale;
			
			v2f vert (appdata v)
			{
				v2f o;
				float weight_expand = smoothstep(_GrowMin, _GrowMax, (v.texcoord.y - _Grow));
				float weight_end = smoothstep(_EndMin, _EndMax, v.texcoord.y);
				float weight_combined = max(weight_expand, weight_end);
				float3 vertex_offset = v.normal * _Expand * 0.01f * weight_combined;
				float3 vertex_scale = v.normal * _Scale * 0.01;
				float3 final_offset = vertex_offset + vertex_scale;
				v.vertex.xyz = v.vertex.xyz + final_offset;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;
				
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				clip(1.0 - (i.uv.y - _Grow));
				half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
				return col;
			}

            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
