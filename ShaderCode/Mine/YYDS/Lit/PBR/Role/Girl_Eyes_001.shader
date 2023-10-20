/*
ÑÛ¾¦×é³É£º
sclera ¹®Ä¤£¬¼´ÑÛ°×
Iris ºçÄ¤
Pupil Í«¿×
Limbus ½ÇÄ¤Ôµ
Cornea ½ÇÄ¤
*/
Shader "TA/Lit/PBR/Role/Girl_Eyes_001"
{
    Properties
    {
        _ScleraMap ("Sclera Map", 2D) = "white" {}
        _ScleraNormalMap ("Sclera Normal Map", 2D) = "bump" {}
        _IrisMap ("Iris Map", 2D) = "white" {}
        _IrisNormalMap ("Iris Normal Map", 2D) = "bump" {}
        _EyeDirNormal ("Eye Dir Normal Map", 2D) = "bump" {}
        _IrisHeightMap ("Iris Height Map", 2D) = "white" {}

        _IrisRadius("Iris Radius", Range(0, 1)) = 0.136
        _PupilScale("Pupil Scale", Range(0, 2)) = 0.8
        _IOR("IOR", Range(1, 2)) = 1.75
        _IrisConcavityScale("IrisConcavityScale", Range(0.1, 5)) = 0
        _EnvRotation("Evn Rotation", Range(-180, 180)) = 0

    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }
        LOD 300

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM
            #pragma target 3.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _Test

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "../../../Library/PBRLighting_Eye.hlsl"

            TEXTURE2D(_ScleraMap); SAMPLER(sampler_ScleraMap);
            TEXTURE2D(_ScleraNormalMap); SAMPLER(sampler_ScleraNormalMap);
            TEXTURE2D(_IrisMap); SAMPLER(sampler_IrisMap);
            TEXTURE2D(_IrisNormalMap); SAMPLER(sampler_IrisNormalMap);
            TEXTURE2D(_EyeDirNormal); SAMPLER(sampler_EyeDirNormal);
            TEXTURE2D(_IrisHeightMap); SAMPLER(sampler_IrisHeightMap);

            CBUFFER_START(UnityPerMaterial)
            float _IrisRadius, _PupilScale, _IOR, _IrisConcavityScale, _EnvRotation;
			CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 tangentOS : TANGENT;
                float3 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 tangentWS : TEXCOORD1;
                float4 bitangentWS : TEXCOORD3;
                float4 normalWS : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


            Varyings Vertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(positionWS);
                
                output.uv = input.texcoord;

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.tangentWS = float4(normalInput.tangentWS, positionWS.x);
                output.bitangentWS = float4(normalInput.bitangentWS, positionWS.y);
                output.normalWS = float4(normalInput.normalWS, positionWS.z);

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target
            {
                half3 debugCol;

                UNITY_SETUP_INSTANCE_ID(input);

                // get info
                float3 tangentWS = input.tangentWS.xyz;
                float3 bitangentWS = input.bitangentWS.xyz;
                float3 normalWS = input.normalWS.xyz;
                float3 positionWS = float3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
                float3x3 TBN = float3x3(tangentWS, bitangentWS, normalWS);
                
                float3 V = GetWorldSpaceNormalizeViewDir(positionWS);

                float len = distance(input.uv, 0.5.xx);
                float irisMask = smoothstep(_IrisRadius, _IrisRadius-0.05, len);

                float4 scleraMap = SAMPLE_TEXTURE2D(_ScleraMap, sampler_ScleraMap, input.uv);
                float4 scleraNormalMap = SAMPLE_TEXTURE2D(_ScleraNormalMap, sampler_ScleraNormalMap, input.uv);
                float3 tangentSceleraNormal = UnpackNormalScale(scleraNormalMap, 0.1);
                float3 tangentSceleraNormal_lerp = lerp(tangentSceleraNormal, float3(0,0,1), irisMask);
                float3 N = TransformTangentToWorld(tangentSceleraNormal_lerp, TBN);

                // ÕÛÉä
                float3 eyeDirNormal_tangent = UnpackNormal(SAMPLE_TEXTURE2D(_EyeDirNormal, sampler_EyeDirNormal, input.uv));
                float3 worldEyeDir = TransformTangentToWorld(eyeDirNormal_tangent, TBN);
                float4 irisHeightMap = SAMPLE_TEXTURE2D(_IrisHeightMap, sampler_IrisHeightMap, input.uv);
                float4 irisHeightMap_Limbus = SAMPLE_TEXTURE2D(_IrisHeightMap, sampler_IrisHeightMap, float2(0.5+_IrisRadius,0.5));
                float irisDepth = max(irisHeightMap.r - irisHeightMap_Limbus.r, 0) * 2;
                float irisConcavity = 0;
                float2 uv_iris;
                EyeRefraction_float(input.uv,normalWS,V,_IOR,_IrisRadius,irisDepth,worldEyeDir,tangentWS,uv_iris,irisConcavity);
                
                // ÎÞÕÛÉä
                //uv_iris = (input.uv - float2(0.5,0.5)) / _IrisRadius * 0.5 + float2(0.5,0.5);

                // Í«¿×Ëõ·Å
                uv_iris = ScaleUVFromCircle(uv_iris, _PupilScale);

                // °µ»·limbus
                float limbus = smoothstep(_IrisRadius, _IrisRadius-0.1, len);
                float4 irisMap = SAMPLE_TEXTURE2D(_IrisMap, sampler_IrisMap, uv_iris) * limbus;
                debugCol = irisMap.rgb;

                // ºçÄ¤·¨Ïß
                float3 irisNormal_tangent = UnpackNormal(SAMPLE_TEXTURE2D(_IrisNormalMap, sampler_IrisNormalMap, uv_iris));
                float3 irisNormal_blend = BlendNormal(irisNormal_tangent, eyeDirNormal_tangent);
                float3 irisNormal = mul(irisNormal_blend, TBN);

                // ½¹É¢
                float causticWeight = irisConcavity * _IrisConcavityScale * irisMask;
                float3 causticNormal = lerp(irisNormal, -N, causticWeight);     // ²Î¿¼UE4´úÂë£ºEyeBxDF

                float3 diffCol = lerp(scleraMap.rgb, irisMap.rgb, irisMask);
                float3 specCol = (0.04).xxx;

                float3 pbrLighing = PBRLighting_Eye(diffCol, specCol, positionWS, N, irisNormal, causticNormal, irisMask, _EnvRotation);
                
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
            #pragma target 3.0

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            float3 _LightDirection;
            float3 _LightPosition;

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv           : TEXCOORD0;
                float4 positionCS   : SV_POSITION;
            };

            float4 GetShadowPositionHClip(Attributes input)
            {
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

            #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                float3 lightDirectionWS = normalize(_LightPosition - positionWS);
            #else
                float3 lightDirectionWS = _LightDirection;
            #endif

                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

            #if UNITY_REVERSED_Z
                positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
            #else
                positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
            #endif

                return positionCS;
            }

            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);

                output.uv = input.texcoord;
                output.positionCS = GetShadowPositionHClip(input);
                return output;
            }

            half4 ShadowPassFragment(Varyings input) : SV_TARGET
            {
                return 0;
            }

            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ColorMask 0

            HLSLPROGRAM
            #pragma target 3.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 position     : POSITION;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv           : TEXCOORD0;
                float4 positionCS   : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings DepthOnlyVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);

                output.uv = input.texcoord;
                output.positionCS = TransformObjectToHClip(input.position.xyz);
                return output;
            }

            half4 DepthOnlyFragment(Varyings input) : SV_TARGET
            {
                return 0;
            }

            ENDHLSL
        }

        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            HLSLPROGRAM
            #pragma target 3.0

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 tangentOS : TANGENT;
                float3 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 tangentWS : TEXCOORD1;
                float4 bitangentWS : TEXCOORD3;
                float4 normalWS : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


            Varyings DepthNormalsVertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(positionWS);
                
                output.uv = input.texcoord;

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.tangentWS = float4(normalInput.tangentWS, positionWS.x);
                output.bitangentWS = float4(normalInput.bitangentWS, positionWS.y);
                output.normalWS = float4(normalInput.normalWS, positionWS.z);

                return output;
            }


            half4 DepthNormalsFragment(Varyings input) : SV_TARGET
            {
                // get info
                float3 tangentWS = input.tangentWS.xyz;
                float3 bitangentWS = input.bitangentWS.xyz;
                float3 normalWS = input.normalWS.xyz;
                float3 positionWS = float3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
                float3x3 TBN = float3x3(tangentWS, bitangentWS, normalWS);

                float4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv);
                float3 N = mul(UnpackNormal(normalMap), TBN);
                return half4(N, 0);
            }


            ENDHLSL
        }

    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }
        LOD 200

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


            Varyings Vertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }

            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                return half4(0, 1, 0, 1);
            }
            
            ENDHLSL
        }

    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }
        LOD 100

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


            Varyings Vertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }

            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                return half4(0, 0, 1, 1);
            }
            
            ENDHLSL
        }

    }


    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
