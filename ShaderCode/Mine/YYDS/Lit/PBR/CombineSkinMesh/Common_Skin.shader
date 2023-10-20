Shader "TA/Lit/PBR/Common_Skin"
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

        // 纹理------------------------------------------------------------>
        [Foldout(1,2,0,0)]
        _FoldoutLighting("光照设置_Foldout", float) = 1

        // 漫反射，三层上色
        [Tex] [NoScaleOffset] _DiffuseRamp("渐变纹理", 2D) = "white"{}
		_TintLayer1("第一层上色颜色", Color) = (0.5,0.5,0.5,1)
		_TintLayer1_Offset("第一层上色偏移值", Range(-1,1)) = 0
		_TintLayer1_RampV("第一层上色软硬过渡", Range(0,1)) = 0.5

		_TintLayer2("第二层上色颜色",Color) = (0.5,0.5,0.5,0)
		_TintLayer2_Offset("第二层上色偏移值", Range(-1,1)) = 0
		_TintLayer2_RampV("第二层上色软硬过渡", Range(0,1)) = 0.8
		
        /*
        _TintLayer3("TintLayer3 Color",Color) = (0.5,0.5,0.5,0)
		_TintLayer3_Offset("TintLayer3 Offset", Range(-1,1)) = 0
		_TintLayer3_RampV("TintLayer3 Ramp V", Range(0,1)) = 1
		*/

        // 高光反射
		_SpecColor("高光颜色",Color) = (0.5,0.5,0.5,1)

        [Foldout_Out(1)]
        _FoldoutOutLighting("光照设置_Foldout", float) = 1
        // 纹理<------------------------------------------------------------

        // 贴花，纹身之类------------------------------------------------------------>
        [Foldout(1,2,0,0)]
        _FoldoutTattoo("贴花，纹身之类_Foldout", float) = 1

        [Tex] [NoScaleOffset] _Tattoo1Tex ("贴花一", 2D) = "black" {}
        _Tattoo1Color ("贴花一颜色", Color) = (1, 1, 1, 1)
        _Tattoo1Pos ("贴花一位置", Vector) = (0.5, 0.5, 0.5, 0.5)
        _TattooTex1Strength ("贴花一强度", Range(0, 1)) = 1

        [Tex] [NoScaleOffset] _Tattoo2Tex ("贴花二", 2D) = "black" {}
		_Tattoo2Zoom("贴花二缩放", float) = 8
        _Tattoo2Rect ("贴花二区域(左下位置，右上位置)", Vector) = (0.106, 0.545, 0.269, 0.64)
        _Tattoo2PosX ("贴花二位置x", Range(0, 1)) = 0.5
        _Tattoo2PosY ("贴花二位置y", Range(0, 1)) = 0.5
        [Toggle_Switch] _Tattoo2Rotate("贴花二是否旋转", float) = 0
		[SwitchAnd(_Tattoo2Rotate)] _Tattoo2RotateRadian("贴花二旋转角度", float) = 0

        [Foldout_Out(1)]
        _FoldoutOutTattoo("贴花，纹身之类_Foldout", float) = 1
        // 贴花，纹身之类<------------------------------------------------------------

        [Toggle_Switch] _DebugMode("是否是调试模式", float) = 0
    }


    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }
        LOD 500

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _DEBUGMODE_ON
            #pragma multi_compile_fragment _ _TATTOO2ROTATE_ON

            // -------------------------------------
            // Universal Pipeline keywords
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            //#pragma multi_compile_fragment _ _SHADOWS_SOFT
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
            #include "BRDF_Skin.hlsl"

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
            TEXTURE2D(_DiffuseRamp); SAMPLER(sampler_DiffuseRamp);
            TEXTURE2D(_Tattoo1Tex); SAMPLER(sampler_Tattoo1Tex);
            TEXTURE2D(_Tattoo2Tex); SAMPLER(sampler_Tattoo2Tex);
            
            CBUFFER_START(UnityPerMaterial)
            half4 _TintLayer1;
			half _TintLayer1_Offset;
            half _TintLayer1_RampV;
			half4 _TintLayer2;
			half _TintLayer2_Offset;
            half _TintLayer2_RampV;
            /*
			half4 _TintLayer3;
			float _TintLayer3_Offset;
            float _TintLayer3_RampV;
            */

			half4 _SpecColor;

            half4 _Tattoo1Color;
            half4 _Tattoo1Pos;
            half _TattooTex1Strength;
            half _Tattoo2Zoom;
            half4 _Tattoo2Rect;
            half _Tattoo2PosX;
            half _Tattoo2PosY;
            #if _TATTOO2ROTATE_ON
                half _Tattoo2RotateRadian;
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

                // 采样
                half2 uv = input.uv;
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                half3 baseColor = baseMap.rgb;

                // 脸部红晕等
                half2 tattoo1UV = (uv - _Tattoo1Pos.xy) * _Tattoo1Pos.zw + 0.5.xx;
                half4 tattoo1Col = SAMPLE_TEXTURE2D(_Tattoo1Tex, sampler_Tattoo1Tex, tattoo1UV);
                baseColor = lerp(baseColor, _Tattoo1Color.rgb * tattoo1Col.rgb, tattoo1Col.a * _TattooTex1Strength);

                half tattoo2_u = lerp(_Tattoo2Rect.x, _Tattoo2Rect.z, _Tattoo2PosX);
                half tattoo2_v = lerp(_Tattoo2Rect.y, _Tattoo2Rect.w, _Tattoo2PosY);
                half2 tattoo2UV = (uv - half2(tattoo2_u, tattoo2_v)) * _Tattoo2Zoom; // 缩放
                #if _TATTOO2ROTATE_ON
                    tattoo2UV = RotateAroundByRadian(_Tattoo2RotateRadian, tattoo2UV); // 旋转
                #endif
                tattoo2UV += 0.5.xx;
                half4 tattoo2Col = SAMPLE_TEXTURE2D(_Tattoo2Tex, sampler_Tattoo2Tex, tattoo2UV);
                baseColor = lerp(baseColor, tattoo2Col.rgb, tattoo2Col.a);

                // 法线
                half4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv);
                half3 tangentNormal = UnpackNormal(normalMap);
                half3 N = TransformTangentToWorld(tangentNormal, TBN);

                // 光照数据
                half3 V = GetWorldSpaceNormalizeViewDir(positionWS);
                Light mainLight = GetMainLight_ta(positionWS);
                half3 L = mainLight.direction;

                half3 finalColor = half3(0,0,0);

				// 漫反射
                half3 diffL = -GetViewForwardDir(); // 取摄像机前方方向作为光源方向
                half NoL = dot(N, diffL);
				half halfLambert = NoL * 0.5 + 0.5;
				half diffuseTerm = halfLambert;

                half3 finalDiffuse = baseColor;
				// 第一层上色
				half2 uvRamp1 = half2(diffuseTerm + _TintLayer1_Offset, _TintLayer1_RampV);
				half toonDiffuse1 = SAMPLE_TEXTURE2D(_DiffuseRamp, sampler_DiffuseRamp, uvRamp1).r;
				half3 tintColor1 = lerp(half3(1, 1, 1), _TintLayer1.rgb, toonDiffuse1 * _TintLayer1.a);
				finalDiffuse *= tintColor1;

				// 第二层上色
				half2 uvRamp2 = half2(diffuseTerm + _TintLayer2_Offset, _TintLayer2_RampV);
				half toonDiffuse2 = SAMPLE_TEXTURE2D(_DiffuseRamp, sampler_DiffuseRamp, uvRamp2).g;
				half3 tintColor2 = lerp(half3(1, 1, 1), _TintLayer2.rgb, toonDiffuse2 * _TintLayer2.a);
				finalDiffuse *= tintColor2;

                /*
				// 第三层上色
				half2 uvRamp3 = half2(diffuseTerm + _TintLayer3_Offset, _TintLayer3_RampV);
				half toonDiffuse3 = SAMPLE_TEXTURE2D(_DiffuseRamp, sampler_DiffuseRamp, uvRamp3).b;
				half3 tintColor3 = lerp(half3(1, 1, 1), _TintLayer3.rgb, toonDiffuse3 * _TintLayer3.a);
				finalDiffuse *= tintColor3;
                */

                finalColor += finalDiffuse;

				// 高光反射
                half3 finalSpec = BlinnPhong_SpecularSkin(_SpecColor.rgb, N, L, V);
                finalColor += finalSpec;

                // 环境反射
                half3 envColor = IndirectLighting_Skin(baseColor, N);
                finalColor += envColor;

                #if _DEBUGMODE_ON
                    debugCol = tattoo2Col.rgb;
                    finalColor = debugCol;
                #endif

                finalColor = saturate(finalColor);
				return float4(finalColor, 1.0);
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
				return baseMap;
            }
            
            ENDHLSL
        }

    }


    FallBack "Hidden/Universal Render Pipeline/FallbackError"

    CustomEditor "TATools.SimpleShaderGUI"

}
