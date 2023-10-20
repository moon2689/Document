Shader "TA/Unlit/Feature/Post Process Distort"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _NoiseTex("Noise Texture", 2D) = "black" {}
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
            Cull Off
            ZWrite Off
            ZTest Always

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_NoiseTex); SAMPLER(sampler_NoiseTex);

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
                float2 uv_NoiseTex = i.uv * 10 + _Time.xx * 5;
                half4 noiseTex = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, uv_NoiseTex);
                float2 uv_MainTex = i.uv + noiseTex.xx * 0.01;
                half4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv_MainTex);
                return mainTex;
            }

            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}