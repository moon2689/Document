Shader "RuoXi/URP/Lit/PBR/PBR RuoXi Body"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _SpecularMap("Specular Map", 2D) = "black" {}
        _SSSLut("SSS Lut", 2D) = "black" {}

        _Lobe1Roughness("Lobe1 Roughness", Range(0.05, 1)) = 0.65
        _Lobe2Roughness("Lobe2 Roughness", Range(0.05, 1)) = 0.25
        _LobeRatio("Lobe Ratio", Range(0, 1)) = 0.85
        _SpecIntensity("Specular Intensity", Range(0, 5)) = 0.35
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
            #pragma multi_compile _ _ADDITIONAL_LIGHTS

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "PBRLightingSkin.hlsl"

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
            TEXTURE2D(_SpecularMap); SAMPLER(sampler_SpecularMap);
            TEXTURE2D(_SSSLut); SAMPLER(sampler_SSSLut);
            float _Lobe1Roughness, _Lobe2Roughness, _LobeRatio, _SpecIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.clipPos = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = normalize(mul(float4(v.normal, 0), unity_WorldToObject).xyz);
                o.worldTangent = normalize(mul(unity_ObjectToWorld, v.tangent).xyz);
                o.worldBinormal = normalize(cross(o.worldNormal, o.worldTangent) * v.tangent.w);
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
                float4 specMap = SAMPLE_TEXTURE2D(_SpecularMap, sampler_SpecularMap, i.uv);
                
                float4 srcNormalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv);
                float3 N = mul(UnpackNormal(srcNormalMap), TBN);
                float4 srcNormalMap_blur = SAMPLE_TEXTURE2D_LOD(_NormalMap, sampler_NormalMap, i.uv, 9);
                float3 N_blur = mul(UnpackNormal(srcNormalMap_blur), TBN);

                float3 diffuseCol = baseMap.rgb;
                float3 specCol = specMap.rrr * _SpecIntensity;
                float occlusion = 1;
                float lobe2Weight = 1-_LobeRatio;

                float3 pbrLighing= PBRLighting_Skin(baseMap, specCol, N, N_blur, worldPos, _Lobe1Roughness, _Lobe2Roughness, lobe2Weight,
                                                    occlusion, _SSSLut, sampler_SSSLut,0,0);
                
                debugCol = specCol;
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
