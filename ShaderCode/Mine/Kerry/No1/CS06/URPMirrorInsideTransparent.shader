Shader "MyURP/Kerry/Unlit/URPMirrorInsideTransparent"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
		_EmissIntensity("EmissIntensity", Float) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent"
        }

        Pass
        {
		    Stencil
		    {
			    Ref 1
			    Comp Equal
			    Pass Keep
			    Fail Keep
			    ZFail Keep
		    }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
		    float _EmissIntensity;

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
                half4 col = half4(baseMap.rgb * _EmissIntensity, baseMap.a);
                return col;
            }

            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
