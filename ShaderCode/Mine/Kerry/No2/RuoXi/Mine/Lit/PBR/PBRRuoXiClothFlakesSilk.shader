Shader "RuoXi/URP/Lit/PBR/PBRRuoXiClothFlakesSilk"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _BaseMap ("Base Map", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _RoughnessMap ("Roughness Map", 2D) = "white" {}
        _Anisotropic ("Anisotropic", Range(-1, 1)) = 0
        _NormalScale ("Normal Scale", Range(0, 5)) = 0

        _FlakesNoiseMap ("Flakes Noise Map", 2D) = "black" {}
        _FlakesColor ("Flakes Color", Color) = (0,0,0,0)
        _FlakesRoughness ("Flakes Roughness", Range(0.05, 1)) = 0.05
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "PBRLightingClothFlakesSilk.hlsl"

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
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
            TEXTURE2D(_RoughnessMap); SAMPLER(sampler_RoughnessMap);
            float4 _Color;
            float _Anisotropic, _NormalScale;
            
            TEXTURE2D(_FlakesNoiseMap); SAMPLER(sampler_FlakesNoiseMap);
            float4 _FlakesNoiseMap_ST;
            float _FlakesRoughness;
            float3 _FlakesColor;

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
                half3 debugCol;

                float3 worldPos = i.worldPos;
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldTangent = normalize(i.worldTangent);
                float3 worldBinormal = normalize(i.worldBinormal);
                float3x3 TBN = float3x3(worldTangent, worldBinormal, worldNormal);

                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv) * _Color;
                
                float4 roughnessMap = SAMPLE_TEXTURE2D(_RoughnessMap, sampler_RoughnessMap, i.uv);
                float roughness = roughnessMap.r;
                float metal = roughnessMap.g;
                float height = roughnessMap.b;
                //float opaque = roughnessMap.a;
                //clip(opaque - 0.5);

                float4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv);
                float3 tangentNormal = UnpackNormal(normalMap);
                float3 N = TransformTangentToWorld(tangentNormal, TBN);

                // 让高光受到法线图的影响
                float3 tangentT = normalize(float3(1, 0, _NormalScale * tangentNormal.x));
                float3 tangentB = normalize(float3(0, 1, _NormalScale * tangentNormal.y));
                float3 T = TransformTangentToWorld(tangentT, TBN);
                float3 B = TransformTangentToWorld(tangentB, TBN);

                float3 diffuseCol = baseMap.rgb * (1 - metal);
                float3 specCol = lerp(float3(0.04, 0.04, 0.04), baseMap.rgb, metal);

                // Flakes
                float2 uv_FlakesMap = i.uv * _FlakesNoiseMap_ST.xy + _FlakesNoiseMap_ST.zw;
                float4 flakesNoiseMap = SAMPLE_TEXTURE2D(_FlakesNoiseMap, sampler_FlakesNoiseMap, uv_FlakesMap);
                float3 flakesTangentNormal = float3((flakesNoiseMap.r*2-1).xx, 1);
                float3 normalFlake = normalize(TransformTangentToWorld(flakesTangentNormal, TBN));

                float3 pbrLighing = PBRLighting_FlakesSilk(diffuseCol, specCol, worldPos, N, T, B, roughness, _Anisotropic, _FlakesColor, normalFlake, _FlakesRoughness);

                //debugCol = FlakesColorMap.rgb;
                //pbrLighing = debugCol;
                return half4(pbrLighing, 1);
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
