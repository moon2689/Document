Shader "TA/Lit/PBR/Common_HairSimple"
{
    Properties
    {
        // 纹理------------------------------------------------------------>
        [Foldout(1,2,0,0)]
        _FoldoutTextures("纹理_Foldout", float) = 1
        [Tex] [NoScaleOffset] _BaseMap("Base Map", 2D) = "white" {}
        [Tex] [NoScaleOffset] _NormalMap("Normal Map", 2D) = "bump" {}
        [Foldout_Out(1)]
        _FoldoutOutTextures("纹理_Foldout", float) = 1
        // 纹理<------------------------------------------------------------

        // 选项------------------------------------------------------------>
        //[Header(Options)]
        [Foldout(1,2,0,0)]
        _FoldoutOptions("选项_Foldout", float) = 1
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull Mode", Float) = 2
        _ClipValue("Clip Value", Range(0,1)) = 0.5
        [Foldout_Out(1)]
        _FoldoutOutOptions("选项_Foldout", float) = 1
        // 选项<------------------------------------------------------------

        // 设置------------------------------------------------------------>
        //[Header(Default)]
        [Foldout(1,2,0,0)]
        _FoldoutDefault("设置_Foldout", float) = 1

        [Toggle_Switch] _HairMask("是否需要头发遮罩", float) = 0
        [Range(_HairMask)] _HairMaskURange("头发遮罩U坐标", Vector) = (0,1,0,1)
        [Range(_HairMask)] _HairMaskVRange("头发遮罩V坐标", Vector) = (0,1,0,1)
        [Switch(_HairMask)] _HeadwearDiffuseIntensity("头饰漫反射强度", float) = 1

        _BaseColor("基础颜色", Color) = (1,1,1,1)
        _SpecColor("高光颜色", Color) = (0.5,0.5,0.5,0)
        [Tex] [NoScaleOffset] _ShiftMap("高光噪声图", 2D) = "black" {}
		_SpecShiftNoiseOffset("高光噪声偏移量", float) = -0.4
		_Roughness("粗糙度", Range(0,1)) = 0.5

        [Header(Env)]
        [Toggle_Switch] _Env("是否有环境光", float) = 1
        [Tex(_Env)] [NoScaleOffset] _EnvCube("环境Cube", Cube) = "black" {}

        [Header(Other)]
        [Toggle_Switch] _FixErrorNormal("是否修复错误法线", float) = 0
        [Toggle_Switch] _DebugMode("是否是调试模式", float) = 0

        [Foldout_Out(1)]
        _FoldoutOutDefault("设置_Foldout", float) = 1
        // 默认设置<------------------------------------------------------------
    }


    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "RenderQueue" = "AlphaTest"
        }
        LOD 500

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            Cull [_Cull]

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ENV_ON
            #pragma shader_feature_local_fragment _HAIRMASK_ON
            #pragma shader_feature_local_fragment _FIXERRORNORMAL_ON
            #pragma shader_feature_local_fragment _DEBUGMODE_ON

            // -------------------------------------
            // Universal Pipeline keywords
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            //#pragma multi_compile_fragment _ _SHADOWS_SOFT
            //#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
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
            #include "BRDF_Cloth.hlsl"

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
            TEXTURE2D(_ShiftMap); SAMPLER(sampler_ShiftMap);

            #if _ENV_ON
                TEXTURECUBE(_EnvCube); SAMPLER(sampler_EnvCube);
            #endif

            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
			half _Roughness;
            half _SpecShiftNoiseOffset;
            half4 _SpecColor;
            half _ClipValue;

            #if _ENV_ON
                half4 _EnvCube_HDR;
            #endif

            #if _HAIRMASK_ON
                half4 _HairMaskURange;
                half4 _HairMaskVRange;
                half _HeadwearDiffuseIntensity;
            #endif
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

                // TBN
                float3 tangentWS = input.tangentWS.xyz;
                float3 bitangentWS = input.bitangentWS.xyz;
                float3 normalWS = input.normalWS.xyz;
                float3 positionWS = float3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
                float3x3 TBN = float3x3(tangentWS, bitangentWS, normalWS);

                half2 uv = input.uv;
                half maskHair = 1;
                #if _HAIRMASK_ON
                    maskHair = min(step(_HairMaskURange.x, uv.x), step(uv.x, _HairMaskURange.y));
                    maskHair = min(maskHair, step(_HairMaskVRange.x, uv.y));
                    maskHair = min(maskHair, step(uv.y, _HairMaskVRange.y));
                #endif

                // 采样
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                half3 baseColor = baseMap.rgb * _BaseColor.rgb * _BaseColor.a;

                #if _HAIRMASK_ON
                    baseColor = lerp(baseMap.rgb * _HeadwearDiffuseIntensity, baseColor, maskHair);
                #endif

                half alpha = baseMap.a;
                clip(alpha - _ClipValue);

                // 法线
                half4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv);
                half3 tangentNormal = UnpackNormal(normalMap);
                half3 N = TransformTangentToWorld(tangentNormal, TBN);

                // 准备光照计算数据
                half3 diffCol = baseColor;
                half3 specCol = 0.04.xxx;
                half roughness = max(0.05, _Roughness);
                half3 finalColor = half3(0, 0, 0);

                // 光照计算
                half3 worldPos = positionWS;
                half3 V = GetWorldSpaceNormalizeViewDir(worldPos);
                Light mainLight = GetMainLight_ta(worldPos);
                half NoV = saturate(abs(dot(N, V))+1e-5);

                // 漫反射
                half3 diffuseLighting = half3(0,0,0);
                half halfLambert;
                #if _FIXERRORNORMAL_ON
                    diffuseLighting = Diffuse_FixN(mainLight, diffCol, N, V, halfLambert);
                #else
                    diffuseLighting = HalfLambert_Diffuse(mainLight, diffCol, N, V, halfLambert);
                #endif
                finalColor += diffuseLighting;

                // 头发高光
                half2 uv_hairNoise = uv * half2(10, 1);
                half3 specHair = SpecularLighting_HairWithNoise(_SpecColor.rgb, _ShiftMap, sampler_ShiftMap, uv_hairNoise, _SpecShiftNoiseOffset, bitangentWS, N, V, halfLambert);
                finalColor += specHair * maskHair;

                // 环境光
                #if _ENV_ON
                    half3 indirectLighting = IndirectLighting_Custom(diffCol, specCol, N, V, NoV, roughness, _EnvCube, sampler_EnvCube, _EnvCube_HDR);
                    finalColor += indirectLighting;
                #endif

                #if _DEBUGMODE_ON
                    debugCol = maskHair.xxx;
                    finalColor = debugCol;
                #endif

                finalColor = saturate(finalColor);
				return float4(finalColor, alpha);
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
        }
        LOD 100

        Pass
        {
            Name "CommonLOD100"

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            // 选项
            #pragma shader_feature_local_fragment _CLIP_ON
            #pragma shader_feature_local_fragment _ISOPAQUE_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
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
                float4 bitangentWS : TEXCOORD2;
                float4 normalWS : TEXCOORD3;
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

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                half2 uv = input.uv;
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                half4 finalColor;
                finalColor.rgb = baseMap.rgb * _BaseColor.rgb * _BaseColor.a;
                finalColor.a = baseMap.a;
				return finalColor;
            }
            
            ENDHLSL
        }

    }


    FallBack "Hidden/Universal Render Pipeline/FallbackError"

    CustomEditor "TATools.SimpleShaderGUI"

}
