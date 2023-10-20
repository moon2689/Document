Shader "RuoXi/URP/Lit/PBR/PBRRuoXiClothCotton"
{
    Properties
    {
        _BaseMap("Base Map", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _RoughnessMap("Roughness Map", 2D) = "white" {}
        _SheenDFGLut("Sheen DFG Lut Map", 2D) = "black" {}
        _FuzzMap("Fuzz Map", 2D) = "white" {}
        _SheenColor("Sheen Color", Color) = (0,0,0,0)
        _SheenRoughness("Shenn Roughness", Range(0, 1)) = 1
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

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // Universal Pipeline keywords
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            //#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            //#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            //#pragma multi_compile_fragment _ _SHADOWS_SOFT

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "PBRLightingClothCotton.hlsl"

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
            TEXTURE2D(_SheenDFGLut); SAMPLER(sampler_SheenDFGLut);
            TEXTURE2D(_FuzzMap); SAMPLER(sampler_FuzzMap);
            float4 _FuzzMap_ST;
            float _SheenRoughness;
            float4 _SheenColor;

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

                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                float4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv);
                float3 normalData = UnpackNormal(normalMap);
                float4 roughnessMap = SAMPLE_TEXTURE2D(_RoughnessMap, sampler_RoughnessMap, i.uv);
                
                worldNormal = mul(normalData, TBN);

                float metal = roughnessMap.g;
                float3 diffuseCol = baseMap.rgb;
                float roughness = roughnessMap.r;

                // fuzz
                float4 sheenColorMap = SAMPLE_TEXTURE2D(_FuzzMap, sampler_FuzzMap, i.uv * _FuzzMap_ST.xy + _FuzzMap_ST.zw);
                float3 sheenColor = sheenColorMap.rgb * _SheenColor;

                // dfg
                float3 viewDir = GetWorldSpaceNormalizeViewDir(worldPos);
                float2 ui_sheenDFG = float2(dot(worldNormal, viewDir), _SheenRoughness);
                float sheenDFG = SAMPLE_TEXTURE2D(_SheenDFGLut, sampler_SheenDFGLut, ui_sheenDFG).r;

                float3 pbrLighing= PBRLighting_Cotton(diffuseCol, sheenColor, worldNormal, worldPos, roughness, 1, _SheenRoughness, sheenDFG);
                
                //debugCol = sheenColorMap.rgb;
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
