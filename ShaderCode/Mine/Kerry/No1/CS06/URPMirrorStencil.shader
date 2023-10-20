Shader "MyURP/Kerry/Unlit/URPMirrorStencil"
{
    Properties
    {
        _Color("Color", Color) = (0,0,0,0)
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "AlphaTest"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "AlphaTest+10"
        }

        Pass
        {
            ColorMask 0
			Stencil
            {
				Ref 1
				Comp Always
				Pass Replace
			}
			ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            half4 _Color;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_TARGET
            {
                return _Color;
            }

            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
