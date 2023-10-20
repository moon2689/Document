Shader "RuoXi/URP/Lit/PBR/PBRRuoXiHair"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _AlphaMap ("Alpha Map", 2D) = "white" {}
        _NoiseMap ("Noise Map", 2D) = "black" {}
        _CutOff("Cut Off", Range(0, 1)) = 0.5
        _Roughness("Roughness", Range(0.001, 1)) = 0.3
        _Specular("Specular", Range(0, 1)) = 1
        _Scatter("Scatter", Range(0, 1)) = 1
        _NoiseScale("Noise Scale", Range(0, 2)) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            //"RenderType" = "Transparent"
            //"Queue" = "Transparent"
        }
        LOD 100


        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            //Blend SrcAlpha OneMinusSrcAlpha
            //ZWrite Off
            //Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _ADDITIONAL_LIGHTS

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "PBRLightingHair.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 clipPos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 worldTangent : TEXCOORD3;
                float3 worldBinormal : TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_AlphaMap); SAMPLER(sampler_AlphaMap);
            TEXTURE2D(_NoiseMap); SAMPLER(sampler_NoiseMap);
            float _CutOff, _Roughness, _Specular, _Scatter, _NoiseScale;


            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.clipPos = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);

                VertexNormalInputs normalData = GetVertexNormalInputs(v.normal, v.tangent);
                o.worldNormal = normalData.normalWS;
                o.worldTangent = normalData.tangentWS;
                o.worldBinormal = normalData.bitangentWS;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                float3 debugCol;

                float3 worldPos = i.worldPos;
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldTangent = normalize(i.worldTangent);
                float3 worldBinormal = normalize(i.worldBinormal);
                float3x3 TBN = float3x3(worldTangent, worldBinormal, worldNormal);

                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                float4 alphaMap = SAMPLE_TEXTURE2D(_AlphaMap, sampler_AlphaMap, i.uv);
                float4 noiseMap = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, i.uv);
                clip(alphaMap.r - _CutOff);

                float3 tangentBinormal = float3(0, 1, 0);
                tangentBinormal.z += (noiseMap * 2 - 1) * _NoiseScale;
                float3 newWorldNormal = mul(tangentBinormal, TBN);

                float3 diffuseCol = baseMap.rgb;
                
                float3 pbrLighing= PBRLighting_Hair(diffuseCol, _Specular, newWorldNormal, worldPos, _Roughness, _Scatter);
                
                //debugCol = specCol;
                //pbrLighing = debugCol;
                return half4(pbrLighing, alphaMap.r);
            }
            ENDHLSL
        }


        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ColorMask 0

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // -------------------------------------
            // Universal Pipeline keywords

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

    }

    Fallback Off
}
