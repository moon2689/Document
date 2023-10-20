Shader "MyURP/Kerry/Unlit/URPMirrorInsideUnlit"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
		_Cutoff( "Mask Clip Value", Float ) = 0.5
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "AlphaTest+30"
        }

        Pass
        {
            Cull Off
		    Stencil
		    {
			    Ref 1
			    CompFront Equal
			    PassFront Keep
			    FailFront Keep
			    ZFailFront Keep
			    CompBack Equal
			    PassBack Keep
			    FailBack Keep
			    ZFailBack Keep
		    }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
		    float _Cutoff;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag(v2f i) : SV_TARGET
            {
                half4 baseMap = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                clip(baseMap.a - _Cutoff);
                return baseMap;
            }

            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
