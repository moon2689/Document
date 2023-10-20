Shader "TA/Role/Low/Common_ClothSimple"
{
    Properties
    {
        // 纹理------------------------------------------------------------>
        [Foldout(1,2,0,0)]
        _FoldoutTextures("纹理_Foldout", float) = 1
        [Tex] [NoScaleOffset] _BaseMap("基础纹理", 2D) = "white" {}
        [Tex] [NoScaleOffset] _NormalMap("法线纹理", 2D) = "bump" {}
        [Foldout_Out(1)]
        _FoldoutOutTextures("纹理_Foldout", float) = 1
        // 纹理<------------------------------------------------------------

        // 选项------------------------------------------------------------>
        //[Header(Options)]
        [Foldout(1,2,0,0)]
        _FoldoutOptions("选项_Foldout", float) = 1
        [Toggle_Switch] _IsOpaque("是否为固体(否则为半透明)", float) = 1 // 固体/半透明
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("混合 源", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("混合 目标", Float) = 0
        [Enum(Off, 0, On, 1)] _ZWrite ("Z缓存写入", Float) = 1
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("剔除模式", Float) = 2

        [Toggle_Switch(_IsOpaque)] _Clip("剪裁", float) = 0
        [SwitchOr(_Clip)] _ClipValue("剪裁值", Range(0,1)) = 0.5

        [Foldout_Out(1)]
        _FoldoutOutOptions("选项_Foldout", float) = 1
        // 选项<------------------------------------------------------------

        // 特色功能------------------------------------------------------------>
        [Foldout(1,2,0,0)]
        _FoldoutFeatures("特色功能_Foldout", float) = 1

        // 边缘光
        [Header(Fresnel)]
        [Toggle_Switch] _Fresnel("是否有边缘光", float) = 0
        [SwitchOr(_Fresnel)] _FresnelColor("Fresnel Color", Color) = (0,0,0,0)

        // 闪烁效果
        [Header(Flake)]
        [Toggle_Switch] _Flake("是否有闪烁效果", float) = 0
        [Toggle_Switch(_Flake)] _SetFlakeColor("是否指定闪烁颜色(否则为随机颜色)", float) = 0
        [SwitchAnd(_Flake,_SetFlakeColor)] _FlakeColor("闪烁颜色", Color) = (1,1,1,1)
        [Tex(_Flake)] [NoScaleOffset] _FlakeNoiseMap("闪烁噪声图", 2D) = "black" {}
        [SwitchOr(_Flake)] _FlakeParam("闪烁参数(平铺,视线,流动,强度)", Vector) = (5,1,1,3)

        // 珍珠
        [Header(Pearl)]
        [Toggle_Switch] _Pearl("是否有珍珠", float) = 0
        [Range(_Pearl)] _PearlMaskURange("珍珠遮罩U坐标", Vector) = (0,1,0,1)
        [SwitchOr(_Pearl)] _PearlColor("珍珠颜色", Color) = (1,1,1,1)

        // 水雾流动效果
        [Header(FlowWaterFog)]
        [Toggle_Switch] _FlowWaterFog("是否有水雾流动效果", float) = 0
        [SwitchAnd(_FlowWaterFog)] _FlowWaterFogColor("水雾流动效果颜色", Color) = (1,1,1,1)
        [Tex(_FlowWaterFog)] _FlowWaterFogNoiseMap("水雾流动效果噪声图", 2D) = "black" {}
        [SwitchAnd(_FlowWaterFog)] _FlowWaterFogNDisturbIntensity("水雾流动法线扰动强度", float) = 1
        [SwitchAnd(_FlowWaterFog)] _FlowWaterFogIntensity("水雾流动效果强度", float) = 1

        [Foldout_Out(1)]
        _FoldoutOutFeatures("特色功能_Foldout", float) = 1
        // 特色功能<------------------------------------------------------------

        // 设置------------------------------------------------------------>
        //[Header(Default)]
        [Foldout(1,2,0,0)]
        _FoldoutDefault("设置_Foldout", float) = 1

        _AppendColor("混合颜色", Color) = (1,1,1,1)
        _Metallic("金属度", Range(0,1)) = 0
        _DefaultRoughness("粗糙度", Range(0,1)) = 1
        _DefaultDiffIntensity("漫反射强度", float) = 1
        _DefaultSpecIntensity("高光强度", float) = 1

        [Toggle_Switch] _Env("是否有环境光", float) = 1
        [Tex(_Env)] [NoScaleOffset] _EnvCube("Env Cube Map", Cube) = "black" {}
        [Tex] [NoScaleOffset] _MatcapMap("Matcap纹理", 2D) = "black" {}

        [Toggle_Switch] _Specular("是否有高光", float) = 1

        [Toggle_Switch] _FixErrorNormal("是否修复错误法线", float) = 0
        
        [Toggle_Switch] _ClipByWorldPos("是否根据世界坐标剪裁", float) = 0
        _ClipWorldPosParam("剪裁世界坐标位置中心与半径", Vector) = (0,0,0,1)
_LowClothLightIntensity("_LowClothLightIntensity", float) = 1
        [Foldout_Out(1)]
        _FoldoutOutDefault("设置_Foldout", float) = 1
        // 设置<------------------------------------------------------------
    }


    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 500

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            Cull [_Cull]

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            // 选项
            #pragma shader_feature_local_fragment _CLIP_ON
            #pragma shader_feature_local_fragment _ISOPAQUE_ON
            // 特色功能
            #pragma shader_feature_local_fragment _FRESNEL_ON
            #pragma shader_feature_local_fragment _FLAKE_ON
            #pragma shader_feature_local_fragment _SETFLAKECOLOR_ON
            // 水雾流动效果
            #pragma shader_feature_local_fragment _FLOWWATERFOG_ON
            // 设置
            #pragma shader_feature_local_fragment _ENV_ON
            #pragma shader_feature_local_fragment _SPECULAR_ON
            #pragma shader_feature_local_fragment _PEARL_ON
            #pragma shader_feature_local_fragment _FIXERRORNORMAL_ON
            #pragma multi_compile_fragment _CLIPBYWORLDPOS_ON

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

            #include "../../TALibrary/CommonInput.hlsl"
            #include "BRDF_Cloth.hlsl"

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);

            #if _FLAKE_ON
                TEXTURE2D(_FlakeNoiseMap); SAMPLER(sampler_FlakeNoiseMap);
            #endif

            #if _ENV_ON
                TEXTURECUBE(_EnvCube); SAMPLER(sampler_EnvCube);
            #endif

            // 水雾流动效果
            #if _FLOWWATERFOG_ON
                TEXTURE2D(_FlowWaterFogNoiseMap); SAMPLER(sampler_FlowWaterFogNoiseMap);
            #endif

            CBUFFER_START(UnityPerMaterial)
            half4 _AppendColor;
            half _Metallic;
            half _DefaultRoughness;
            half _DefaultDiffIntensity;
            half _DefaultSpecIntensity;

            #if _CLIP_ON
                half _ClipValue;
            #endif

            #if _ENV_ON
                half4 _EnvCube_HDR;
            #endif

            #if _FLAKE_ON
                #if _SETFLAKECOLOR_ON
                    half4 _FlakeColor;
                #endif
                half4 _FlakeParam;
            #endif

            #if _FRESNEL_ON
                half4 _FresnelColor;
            #endif

            #if _PEARL_ON
                half4 _PearlMaskURange;
                half4 _PearlColor;
            #endif

            // 水雾流动效果
            #if _FLOWWATERFOG_ON
                half _FlowWaterFogPassIndex;
                half4 _FlowWaterFogNoiseMap_ST;
                half4 _FlowWaterFogColor;
                half _FlowWaterFogNDisturbIntensity;
                half _FlowWaterFogIntensity;
            #endif

            float4 _ClipWorldPosParam;
			CBUFFER_END

            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                // TBN
                float3 tangentWS = input.tangentWS.xyz;
                float3 bitangentWS = input.bitangentWS.xyz;
                float3 normalWS = input.normalWS.xyz;
                float3 positionWS = float3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
                float3x3 TBN = float3x3(tangentWS, bitangentWS, normalWS);

                // 采样
                half2 uv = input.uv;
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);

                // 遮罩
                half maskCloth = 1;
                #if _PEARL_ON
                    half maskPearl = min(step(_PearlMaskURange.x, uv.x), step(uv.x, _PearlMaskURange.y));
                    maskCloth = min(maskCloth, 1 - maskPearl);
                #endif

                // 基本色
                half diffuseIntensity = _DefaultDiffIntensity;
                half3 baseColor = baseMap.rgb * _AppendColor.rgb * diffuseIntensity;
                #if _PEARL_ON
                    baseColor = lerp(baseColor, _PearlColor.rgb, maskPearl);
                #endif
                half alpha = baseMap.a;

                // 剪裁
                #if _ISOPAQUE_ON && _CLIP_ON
                    clip(alpha - _ClipValue);
                #endif

                // 法线
                half4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv);
                half3 tangentNormal = UnpackNormal(normalMap);
                half3 N = TransformTangentToWorld(tangentNormal, TBN);
                #if _PEARL_ON
                    N = lerp(N, normalWS, maskPearl);
                #endif

                // 粗糙度
                half roughness = max(0.05, _DefaultRoughness);

                // 高光强度
                half specIntensity = _DefaultSpecIntensity;

                // 准备光照计算数据
                half3 V = GetWorldSpaceNormalizeViewDir(positionWS);
                half NoV = saturate(abs(dot(N, V))+1e-5);
                Light mainLight = GetMainLight_ta(positionWS);
                half3 L = mainLight.direction;
                half3 diffCol = baseColor * (1 - _Metallic);
                half3 specCol = lerp(0.04, baseColor, _Metallic) * specIntensity;
                half3 finalColor = half3(0, 0, 0);

                // 水雾流动效果
                #if _FLOWWATERFOG_ON
                    half2 uv_FlowWaterFog = uv * _FlowWaterFogNoiseMap_ST.xy + _Time.xx * _FlowWaterFogNoiseMap_ST.zw + N.xy * _FlowWaterFogNDisturbIntensity;
                    half4 flowWaterFogNoiseMap = SAMPLE_TEXTURE2D(_FlowWaterFogNoiseMap, sampler_FlowWaterFogNoiseMap, uv_FlowWaterFog);
                    half3 finalFlowWaterFog = flowWaterFogNoiseMap.r * _FlowWaterFogColor.rgb * _FlowWaterFogIntensity;
                    diffCol += finalFlowWaterFog;
                #endif

                // 漫反射
                half halfLambert;
                half3 radiance;
                half3 diffuseLighting = half3(0,0,0);
                #if _FIXERRORNORMAL_ON
                    diffuseLighting = BRDF_HarfLambertLighting_FixN(mainLight, diffCol, N, V, radiance, halfLambert);
                #else
                    diffuseLighting = BRDF_HarfLambertLighting(mainLight, diffCol, N, V, radiance, halfLambert);
                #endif
                finalColor += diffuseLighting;

                // 镜面反射
                #if _SPECULAR_ON
                    half3 specLighting = BRDF_StandardSpecularLighting(specCol, N, V, L, NoV, halfLambert, roughness, radiance);
                    finalColor += specLighting;
                #endif

                // 环境光
                #if _ENV_ON
                    half specDFGIntensity = 0;
                    #if _PEARL_ON
                        specDFGIntensity = lerp(specDFGIntensity, 1, maskPearl);
                    #endif
                    half3 indirectLighting = IndirectLighting_Custom(diffCol, specCol, N, V, NoV, roughness, _EnvCube, sampler_EnvCube, _EnvCube_HDR, specDFGIntensity);
                    finalColor += indirectLighting;
                #endif

                // 菲涅尔
                #if _FRESNEL_ON
                    half3 finalFresnelCol = CalcFresnelColor(_FresnelColor.rgb, NoV);
                    finalColor += finalFresnelCol;
                #endif

                // 闪烁效果
                #if _FLAKE_ON
                    half3 flakeCol;
                    #if _SETFLAKECOLOR_ON
                        flakeCol = CalcFlakeColorPow2(_FlakeColor.rgb, _FlakeNoiseMap, sampler_FlakeNoiseMap, V, uv, _FlakeParam);
                    #else
                        flakeCol = CalcFlakeRandomColor(_FlakeNoiseMap, sampler_FlakeNoiseMap, V, NoV, uv, _FlakeParam);
                    #endif
                    finalColor += flakeCol;
                #endif

                // 根据世界坐标位置剪裁
                #if _CLIPBYWORLDPOS_ON
                    ClipRole(positionWS.xyz, _ClipWorldPosParam.xyz, _ClipWorldPosParam.w);
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
        LOD 300

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            Cull [_Cull]

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            // 选项
            #pragma shader_feature_local_fragment _CLIP_ON
            #pragma shader_feature_local_fragment _ISOPAQUE_ON
            // 特色功能
            #pragma shader_feature_local_fragment _FRESNEL_ON
            #pragma shader_feature_local_fragment _FLAKE_ON
            #pragma shader_feature_local_fragment _SETFLAKECOLOR_ON
            // 水雾流动效果
            #pragma shader_feature_local_fragment _FLOWWATERFOG_ON
            // 设置
            #pragma shader_feature_local_fragment _ENV_ON
            #pragma shader_feature_local_fragment _SPECULAR_ON
            #pragma shader_feature_local_fragment _PEARL_ON
            #pragma shader_feature_local_fragment _FIXERRORNORMAL_ON
            #pragma multi_compile_fragment _CLIPBYWORLDPOS_ON

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

            #include "../../TALibrary/CommonInput.hlsl"
            #include "BRDF_Cloth.hlsl"

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);

            #if _FLAKE_ON
                TEXTURE2D(_FlakeNoiseMap); SAMPLER(sampler_FlakeNoiseMap);
            #endif

            #if _ENV_ON
                TEXTURECUBE(_EnvCube); SAMPLER(sampler_EnvCube);
                TEXTURE2D(_MatcapMap); SAMPLER(sampler_MatcapMap);
            #endif

            // 水雾流动效果
            #if _FLOWWATERFOG_ON
                TEXTURE2D(_FlowWaterFogNoiseMap); SAMPLER(sampler_FlowWaterFogNoiseMap);
            #endif

            CBUFFER_START(UnityPerMaterial)
            half4 _AppendColor;
            half _Metallic;
            half _DefaultRoughness;
            half _DefaultDiffIntensity;
            half _DefaultSpecIntensity;

            #if _CLIP_ON
                half _ClipValue;
            #endif

            #if _ENV_ON
                half4 _EnvCube_HDR;
            #endif

            #if _FLAKE_ON
                #if _SETFLAKECOLOR_ON
                    half4 _FlakeColor;
                #endif
                half4 _FlakeParam;
            #endif

            #if _FRESNEL_ON
                half4 _FresnelColor;
            #endif

            #if _PEARL_ON
                half4 _PearlMaskURange;
                half4 _PearlColor;
            #endif

            // 水雾流动效果
            #if _FLOWWATERFOG_ON
                half _FlowWaterFogPassIndex;
                half4 _FlowWaterFogNoiseMap_ST;
                half4 _FlowWaterFogColor;
                half _FlowWaterFogNDisturbIntensity;
                half _FlowWaterFogIntensity;
            #endif

            float4 _ClipWorldPosParam;
			CBUFFER_END

            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                // TBN
                float3 tangentWS = input.tangentWS.xyz;
                float3 bitangentWS = input.bitangentWS.xyz;
                float3 normalWS = input.normalWS.xyz;
                float3 positionWS = float3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
                float3x3 TBN = float3x3(tangentWS, bitangentWS, normalWS);

                // 采样
                half2 uv = input.uv;
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);

                // 遮罩
                half maskCloth = 1;
                #if _PEARL_ON
                    half maskPearl = min(step(_PearlMaskURange.x, uv.x), step(uv.x, _PearlMaskURange.y));
                    maskCloth = min(maskCloth, 1 - maskPearl);
                #endif

                // 基本色
                half diffuseIntensity = _DefaultDiffIntensity;
                half3 baseColor = baseMap.rgb * _AppendColor.rgb * diffuseIntensity;
                #if _PEARL_ON
                    baseColor = lerp(baseColor, _PearlColor.rgb, maskPearl);
                #endif
                half alpha = baseMap.a;

                // 剪裁
                #if _ISOPAQUE_ON && _CLIP_ON
                    clip(alpha - _ClipValue);
                #endif

                // 法线
                half4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv);
                half3 tangentNormal = UnpackNormal(normalMap);
                half3 N = TransformTangentToWorld(tangentNormal, TBN);
                #if _PEARL_ON
                    N = lerp(N, normalWS, maskPearl);
                #endif

                // 粗糙度
                half roughness = max(0.05, _DefaultRoughness);

                // 高光强度
                half specIntensity = _DefaultSpecIntensity;

                // 准备光照计算数据
                half3 V = GetWorldSpaceNormalizeViewDir(positionWS);
                half NoV = saturate(abs(dot(N, V))+1e-5);
                Light mainLight = GetMainLight_ta(positionWS);
                half3 L = mainLight.direction;
                half3 diffCol = baseColor * (1 - _Metallic);
                half3 specCol = lerp(0.04, baseColor, _Metallic) * specIntensity;
                half3 finalColor = half3(0, 0, 0);

                // 水雾流动效果
                #if _FLOWWATERFOG_ON
                    half2 uv_FlowWaterFog = uv * _FlowWaterFogNoiseMap_ST.xy + _Time.xx * _FlowWaterFogNoiseMap_ST.zw + N.xy * _FlowWaterFogNDisturbIntensity;
                    half4 flowWaterFogNoiseMap = SAMPLE_TEXTURE2D(_FlowWaterFogNoiseMap, sampler_FlowWaterFogNoiseMap, uv_FlowWaterFog);
                    half3 finalFlowWaterFog = flowWaterFogNoiseMap.r * _FlowWaterFogColor.rgb * _FlowWaterFogIntensity;
                    diffCol += finalFlowWaterFog;
                #endif

                // 漫反射
                half halfLambert;
                half3 radiance;
                half3 diffuseLighting = half3(0,0,0);
                #if _FIXERRORNORMAL_ON
                    diffuseLighting = BRDF_HarfLambertLighting_FixN(mainLight, diffCol, N, V, radiance, halfLambert);
                #else
                    diffuseLighting = BRDF_HarfLambertLighting(mainLight, diffCol, N, V, radiance, halfLambert);
                #endif
                finalColor += diffuseLighting;

                /*
                // 镜面反射
                #if _SPECULAR_ON
                    half3 specLighting = BRDF_StandardSpecularLighting(specCol, N, V, L, NoV, halfLambert, roughness, radiance);
                    finalColor += specLighting;
                #endif

                // 环境光
                #if _ENV_ON
                    half specDFGIntensity = 0;
                    #if _PEARL_ON
                        specDFGIntensity = lerp(specDFGIntensity, 1, maskPearl);
                    #endif
                    half3 indirectLighting = IndirectLighting_Custom(diffCol, specCol, N, V, NoV, roughness, _EnvCube, sampler_EnvCube, _EnvCube_HDR, specDFGIntensity);
                    finalColor += indirectLighting;
                #endif
                */

                half3 envDiffuse = DiffuseIndirect(diffCol, N);
                finalColor += envDiffuse;
                
                #if _SPECULAR_ON || _ENV_ON
                    // matcap
                    half3 viewN = mul(UNITY_MATRIX_V, float4(N, 0)).xyz;
                    half2 uv_matcap = viewN.xy * 0.5 + float2(0.5, 0.5);
                    half4 matcapColor = SAMPLE_TEXTURE2D(_MatcapMap, sampler_MatcapMap, uv_matcap);
                    half3 matcapLighting = matcapColor.rrr * mainLight.color * specCol;
                    finalColor += matcapLighting;
                #endif

                // 菲涅尔
                #if _FRESNEL_ON
                    half3 finalFresnelCol = CalcFresnelColor(_FresnelColor.rgb, NoV);
                    finalColor += finalFresnelCol;
                #endif

                // 闪烁效果
                #if _FLAKE_ON
                    half3 flakeCol;
                    #if _SETFLAKECOLOR_ON
                        flakeCol = CalcFlakeColorPow2(_FlakeColor.rgb, _FlakeNoiseMap, sampler_FlakeNoiseMap, V, uv, _FlakeParam);
                    #else
                        flakeCol = CalcFlakeRandomColor(_FlakeNoiseMap, sampler_FlakeNoiseMap, V, NoV, uv, _FlakeParam);
                    #endif
                    finalColor += flakeCol;
                #endif

                // 根据世界坐标位置剪裁
                #if _CLIPBYWORLDPOS_ON
                    ClipRole(positionWS.xyz, _ClipWorldPosParam.xyz, _ClipWorldPosParam.w);
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
    
    // BlinnPhong+SH
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
            Tags{"LightMode" = "UniversalForward"}

            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            Cull [_Cull]

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            // 选项
            #pragma shader_feature_local_fragment _CLIP_ON
            #pragma shader_feature_local_fragment _ISOPAQUE_ON
            #pragma multi_compile_fragment _CLIPBYWORLDPOS_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "BRDF_Cloth.hlsl"

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
            half _ClipValue;
            float4 _ClipWorldPosParam;
			CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


            Varyings Vertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(output.positionWS);
                output.uv = input.texcoord;
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);

                return output;
            }
            
            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                float3 normalWS = input.normalWS.xyz;
                float3 positionWS = input.positionWS;

                // 采样
                half2 uv = input.uv;
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                half alpha = baseMap.a;

                // 剪裁
                #if _ISOPAQUE_ON && _CLIP_ON
                    clip(alpha - _ClipValue);
                #endif
                
                half3 baseColor = baseMap.rgb;
                half3 N = normalWS;

                // 准备光照计算数据
                half3 V = GetWorldSpaceNormalizeViewDir(positionWS);
                half3 diffCol = baseColor;
                half3 finalColor = 0;

                // 漫反射
                half3 diffuseLighting = diffCol * (dot(N, V) * 0.7 + 0.3);
                finalColor += diffuseLighting;
                
                // env
                half3 envDiffuse = DiffuseIndirect(diffCol, N);
                finalColor += envDiffuse;

                // 根据世界坐标位置剪裁
                #if _CLIPBYWORLDPOS_ON
                    ClipRole(positionWS.xyz, _ClipWorldPosParam.xyz, _ClipWorldPosParam.w);
                #endif

                return float4(finalColor, alpha);
            }
            
            ENDHLSL
        }
    }
    
    
    // 无光
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 50

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            Cull [_Cull]

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            // 选项
            #pragma shader_feature_local_fragment _CLIP_ON
            #pragma shader_feature_local_fragment _ISOPAQUE_ON
            #pragma multi_compile_fragment _CLIPBYWORLDPOS_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "BRDF_Cloth.hlsl"

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
            half _ClipValue;
            float4 _ClipWorldPosParam;
			CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


            Varyings Vertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(output.positionWS);
                output.uv = input.texcoord;

                return output;
            }
            
            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                // 采样
                half2 uv = input.uv;
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);

                // 剪裁
                #if _ISOPAQUE_ON && _CLIP_ON
                    clip(baseMap.a - _ClipValue);
                #endif

                // 根据世界坐标位置剪裁
                #if _CLIPBYWORLDPOS_ON
                    float3 positionWS = input.positionWS;
                    ClipRole(positionWS.xyz, _ClipWorldPosParam.xyz, _ClipWorldPosParam.w);
                #endif

                return baseMap;
            }
            
            ENDHLSL
        }
    }


    FallBack "Hidden/Universal Render Pipeline/FallbackError"

    CustomEditor "TATools.SimpleShaderGUI"
}
