Shader "RuoXi/URP/Lit/URPBlinnPhong"
{
    Properties
    {
        _BaseMap("Base Map", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _SpecGloss("Specular Gloss", Range(1, 20)) = 8
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
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM

            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS

            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
            float _SpecGloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldTangent : TEXCOORD2;
                float3 worldBinormal : TEXCOORD3;
                float3 worldPos : TEXCOORD4;
                float4 shadowCoord : TEXCOORD5;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = v.uv;
                o.worldNormal = normalize(mul(v.normal, unity_WorldToObject).xyz);
                o.worldTangent = normalize(mul(unity_ObjectToWorld, v.tangent).xyz);
                o.worldBinormal = normalize(cross(o.worldNormal, o.worldTangent) * v.tangent.w);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.shadowCoord = TransformWorldToShadowCoord(o.worldPos);
                return o;
            }

            half4 frag(v2f i) : SV_TARGET
            {
                // get info
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldTangent = normalize(i.worldTangent);
                float3 worldBinormal = normalize(i.worldBinormal);
                float3 worldPos = i.worldPos;

                // sample texture
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                half4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv);
                half3 normalData = UnpackNormal(normalMap);

                // 法线
                float3x3 matrixTNB = float3x3(worldTangent, worldBinormal, worldNormal);
                float3 normal = mul(normalData, matrixTNB);

                // 主光源光照计算
                float4 shadowCoord = i.shadowCoord;
                float3 worldView = GetWorldSpaceNormalizeViewDir(worldPos);
                half3 finalLightCol = half3(0, 0, 0);
                {
                    Light mainLight = GetMainLight(shadowCoord);
                    // diffuse
                    float NdotL = dot(normal, mainLight.direction);
                    NdotL = saturate(NdotL * 0.5 + 0.5);
                    half3 diffuse = baseMap.rgb * mainLight.color * NdotL
                                    * mainLight.shadowAttenuation * mainLight.distanceAttenuation;

                    // specular
                    float3 halfVL = normalize(mainLight.direction + worldView);
                    float NdotH = saturate(dot(normal, halfVL));
                    half3 specular = baseMap.rgb * mainLight.color * pow(NdotH, _SpecGloss)
                                    * mainLight.shadowAttenuation * mainLight.distanceAttenuation;

                    finalLightCol = diffuse + specular;
                }

                // 其它光源光照计算
                #if defined(_ADDITIONAL_LIGHTS)
                uint addLightCount = GetAdditionalLightsCount();
                for(uint lightIndex = 0;lightIndex < addLightCount;++lightIndex)
                {
                    Light addLight = GetAdditionalLight(lightIndex, worldPos, shadowCoord);

                    // diffuse
                    float NdotL = dot(normal, addLight.direction);
                    NdotL = saturate(NdotL * 0.5 + 0.5);
                    half3 diffuse = baseMap.rgb * addLight.color * NdotL
                                     * addLight.shadowAttenuation * addLight.distanceAttenuation;

                    // specular
                    float3 halfVL = normalize(addLight.direction + worldView);
                    float NdotH = saturate(dot(normal, halfVL));
                    half3 specular = baseMap.rgb * addLight.color * pow(NdotH, _SpecGloss)
                                    * addLight.shadowAttenuation * addLight.distanceAttenuation;

                    finalLightCol += (diffuse + specular);
                }
                #endif

                half4 col = half4(finalLightCol, 1);
                return col;
            }

            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
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

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
