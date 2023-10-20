Shader "MyURP/Kerry/URPMirror3"
{
    Properties
    {
		_Matcap("Matcap", 2D) = "white" {}
		_Height("Height", Float) = 0
		_Mirror("Mirror", 2D) = "white" {}
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry+0"
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_Matcap); SAMPLER(sampler_Matcap);
            TEXTURE2D(_Mirror); SAMPLER(sampler_Mirror);
            float _Height;

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

            float4 frag(v2f i) : SV_TARGET
            {
                half4 col = SAMPLE_TEXTURE2D(_Mirror, sampler_Mirror, i.uv + float2(0, _Height));
                return col;
            }

            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
