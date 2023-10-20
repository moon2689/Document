Shader "TA/Unlit/UI/Vos UI Clip"
{
    Properties
    {
        [HideInInspector]_MainTex ("Main Texture", 2D) = "white" {}
        //[Toggle(_CLIP_Y_ON)] _IsCilpY("Y方向是否裁剪",Float) = 0

        [Toggle_Switch] _IsClip_Y("Y方向是否裁剪",Float) = 0
        [SwitchOr(_IsClip_Y)]_ClipMinY ("Clip Min Y", Range(0, 1)) = 0
        [SwitchOr(_IsClip_Y)]_ClipMaxY ("Clip Max Y", Range(0, 1)) = 1
        [Space(20)]
        [Toggle_Switch] _IsAlpha("是否渐隐",Float) = 0
        [SwitchOr(_IsAlpha)]_AlphaLeftStart("AlphaLeftStart", Float) = 0.1
        [SwitchOr(_IsAlpha)]_AlphaLeftEnd("AlphaLeftEnd", Float) = 0.4
        [Space(20)]
        [SwitchOr(_IsAlpha)]_AlphaRightStart("AlphaRightStart", Float) = 0.6
        [SwitchOr(_IsAlpha)]_AlphaRightEnd("AlphaRightEnd", Float) = 0.9
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderPipeline" = "UniversalPipeline"
        }

        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM

            #pragma shader_feature_local_fragment _ISCLIP_Y_ON
            #pragma shader_feature_local_fragment _ISALPHA_ON
        
            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                half4 color : COLOR;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            CBUFFER_START(UnityPerMaterial)
            #if _ISCLIP_Y_ON
                float _ClipMaxY, _ClipMinY;
            #endif

            #if _ISALPHA_ON
                float _AlphaLeftStart, _AlphaLeftEnd, _AlphaRightStart, _AlphaRightEnd;
            #endif
            CBUFFER_END

            v2f vert(appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                
                o.uv = v.texcoord;
                o.color = v.color;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 color = i.color * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                half2 screenUV = GetNormalizedScreenSpaceUV(i.pos);

                #if _ISCLIP_Y_ON
                    float ClipMaxY1 = step(screenUV.y,_ClipMaxY);
                    float ClipMaxY2 = step(_ClipMinY,screenUV.y);
                    color.a *= ClipMaxY1*ClipMaxY2;
                #endif

                #if _ISALPHA_ON
                    float leftFactor = saturate((screenUV.x-_AlphaLeftStart)/(_AlphaLeftEnd-_AlphaLeftStart));
                    color = lerp(0, color, leftFactor);

                    float rightFactor = saturate((screenUV.x-_AlphaRightStart)/(_AlphaRightEnd-_AlphaRightStart));
                    color = lerp(color, 0, rightFactor);
                #endif

                return color;
            }
            ENDHLSL
        }
    }
    CustomEditor "TATools.SimpleShaderGUI"
}
