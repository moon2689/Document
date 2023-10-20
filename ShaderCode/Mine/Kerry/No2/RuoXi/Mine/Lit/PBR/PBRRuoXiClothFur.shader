Shader "RuoXi/URP/Lit/PBR/PBRRuoXiClothFur"
{
    Properties
    {
        [Header(Base)]
        _BaseMap("Base Map", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _Roughness("Roughness", Range(0.05, 1)) = 1

        [Header(SheenColor)]
        _SheenDFGLut("Sheen DFG Lut Map", 2D) = "black" {}
        _SheenColor("Sheen Color", Color) = (0,0,0,0)
        _SheenRoughness("Shenn Roughness", Range(0.05, 1)) = 1
        
        [Header(Fur)]
        _FurNoiseMap("Fur Noise Map", 2D) = "black" {}
        _FurWindMap("Fur Wind Map", 2D) = "black" {}
        _FurLen("Fur Length", Range(0.1, 5)) = 0.1
        _FurClip("Fur Clip", Range(0, 1)) = 0.5
        _FurWindScale("Fur Wind Scale", Range(0, 2)) = 1
        _FurOcclusion("Fur Occlusion", Range(0, 1)) = 0.5
        _FurDir("Fur Direction", Vector) = (0,0,0,0)
        _FurEdgeFade("Fur Edge Fade", Range(0, 3)) = 1

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
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 clipPos : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 worldTangent : TEXCOORD3;
                float3 worldBinormal : TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
            TEXTURE2D(_SheenDFGLut); SAMPLER(sampler_SheenDFGLut);
            TEXTURE2D(_FurNoiseMap); SAMPLER(sampler_FurNoiseMap);
            TEXTURE2D(_FurWindMap); SAMPLER(sampler_FurWindMap);
            
            float _Roughness, _SheenRoughness;
            float4 _SheenColor;
            float _FurLen, _FurClip, _FurWindScale, _FurOcclusion, _FurEdgeFade;
            float4 _FurNoiseMap_ST, _FurWindMap_ST, _FurDir;


            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float3 offsetPos = v.vertex.xyz + v.normal * _FurLen * v.color.r * 0.01;

                o.clipPos = TransformObjectToHClip(offsetPos);
                o.color = v.color;
                o.uv = v.uv;
                o.worldPos = TransformObjectToWorld(offsetPos);

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
                
                worldNormal = mul(normalData, TBN);

                float3 diffuseCol = baseMap.rgb;
                float roughness = _Roughness;

                // dfg
                float3 viewDir = GetWorldSpaceNormalizeViewDir(worldPos);
                float2 ui_sheenDFG = float2(dot(worldNormal, viewDir), _SheenRoughness);
                float sheenDFG = SAMPLE_TEXTURE2D(_SheenDFGLut, sampler_SheenDFGLut, ui_sheenDFG).r;
                
                // fur
                float furLayer = i.color.r;
                float furLayerPow2 = Pow2(furLayer);
                
                // 风力扰动
                float4 furWindMap = SAMPLE_TEXTURE2D(_FurWindMap, sampler_FurWindMap, i.uv * _FurWindMap_ST.xy);
                float2 furWindLen = (furWindMap.xy * 2 - 1) * furLayer * _FurWindScale;

                //剪裁
                float2 uv_furNoise = i.uv * _FurNoiseMap_ST.xy + _FurDir * furLayerPow2 + furWindLen;
                float4 furNoiseMap = SAMPLE_TEXTURE2D(_FurNoiseMap, sampler_FurNoiseMap, uv_furNoise);
                float furAlpha = furLayer < 0.01 ? 1 : (furNoiseMap.r * 2 - furLayerPow2 * _FurEdgeFade);
                clip(furAlpha - _FurClip);

                // 影响 ao 和 sheen color
                float occlusion = lerp(_FurOcclusion, 1, furLayer);
                float3 sheenColor = _SheenColor * occlusion;

                // lighting
                float3 pbrLighing= PBRLighting_Cotton(diffuseCol, sheenColor, worldNormal, worldPos, roughness, occlusion, _SheenRoughness, sheenDFG);

                //debugCol = occlusion.xxx;
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
