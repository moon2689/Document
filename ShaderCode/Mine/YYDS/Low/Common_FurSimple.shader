Shader "TA/Role/Low/Common_FurSimple"
{
    Properties
    {
        // 设置------------------------------------------------------------>
        [Foldout(1,2,0,0)]
        _FoldoutDefault("设置_Foldout", float) = 1
        
        [Toggle_Switch] _HasBaseMap("是否有基础贴图", float) = 0
		[Tex(_HasBaseMap)] [NoScaleOffset] _BaseMap("基础纹理", 2D) = "white" {}

        _BaseColor("基础颜色", Color) = (1,1,1,1)
        _DiffuseIntensity("漫反射强度", float) = 1

        [Toggle_Switch] _FixErrorNormal("是否修复错误法线", float) = 0

        [Toggle_Switch] _ClipByWorldPos("是否根据世界坐标剪裁", float) = 0
        _ClipWorldPosParam("剪裁世界坐标位置中心与半径", Vector) = (0,0,0,1)
        
        [Foldout_Out(1)]
        _FoldoutOutDefault("设置_Foldout", float) = 1
        // 设置<------------------------------------------------------------

        // 毛皮------------------------------------------------------------>
        [Foldout(1,2,0,0)]
        _FoldoutFur("毛皮_Foldout", float) = 1

        //[Header(Fur)]
        [Tex] [NoScaleOffset] _FurNoiseMap("毛皮噪声图", 2D) = "black" {}
        _FurNoiseTilling("毛皮噪声平铺值", float) = 1
        _FurOcclusion("毛皮环境光遮蔽", Range(0, 1)) = 0.5
        _FurLen("毛皮长度", float) = 0.1
        _FurEdgeFade("毛皮边缘淡出", float) = 1
        _FurClip("毛皮剪裁值", Range(0, 1)) = 0.5

        [Foldout_Out(1)]
        _FoldoutOutFur("毛皮_Foldout", float) = 1
        // 毛皮<------------------------------------------------------------
    }


    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "AlphaTest"
        }
        LOD 500

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            Cull Off

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _HASBASEMAP_ON
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

            #include "BRDF_Cloth.hlsl"

            #if _HASBASEMAP_ON
                TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            #endif

            TEXTURE2D(_FurNoiseMap); SAMPLER(sampler_FurNoiseMap);
            
            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
            half _DiffuseIntensity;

            half _FurNoiseTilling;
            half _FurWindTilling;
            half _FurLen;
            half _FurClip;
            half _FurOcclusion;
            half _FurEdgeFade;

            float4 _ClipWorldPosParam;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 tangentOS : TANGENT;
                float3 normalOS : NORMAL;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 tangentWS : TEXCOORD1;
                float4 bitangentWS : TEXCOORD2;
                float4 normalWS : TEXCOORD3;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings Vertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float3 offsetPos = input.positionOS.xyz + input.normalOS * _FurLen * input.color.r * 0.01;
                float3 positionWS = TransformObjectToWorld(offsetPos);
                output.positionCS = TransformWorldToHClip(positionWS);
                
                output.uv = input.texcoord;
                output.color = input.color;

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.tangentWS = float4(normalInput.tangentWS, positionWS.x);
                output.bitangentWS = float4(normalInput.bitangentWS, positionWS.y);
                output.normalWS = float4(normalInput.normalWS, positionWS.z);

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                // TBN
                float3 tangentWS = input.tangentWS.xyz;
                float3 bitangentWS = input.bitangentWS.xyz;
                float3 normalWS = input.normalWS.xyz;
                float3 positionWS = float3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
                half3 N = normalWS;

                // 基本色
                half3 baseColor = _BaseColor.rgb * _DiffuseIntensity;
                #if _HASBASEMAP_ON
                    half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                    baseColor *= baseMap.rgb;
                #endif

                // 毛皮
                half furLayer = input.color.r;
                half furLayerPow2 = Pow2(furLayer);
                half2 uv_furNoise = input.uv * _FurNoiseTilling;
                half4 furNoiseMap = SAMPLE_TEXTURE2D(_FurNoiseMap, sampler_FurNoiseMap, uv_furNoise);
                half furAlpha = furLayer < 0.01 ? 1 : (furNoiseMap.r * 2 - furLayerPow2 * _FurEdgeFade);
                clip(furAlpha - _FurClip); //剪裁
                half occlusion = lerp(_FurOcclusion, 1, furLayer); //毛皮尝试影响ao

                // 准备光照计算数据
                half3 V = GetWorldSpaceNormalizeViewDir(positionWS);
                //half NoV = saturate(abs(dot(N, V))+1e-5);
                Light mainLight = GetMainLight_ta(positionWS);
                //half3 L = mainLight.direction;
                half3 diffCol = baseColor;
                half3 finalColor = half3(0, 0, 0);

                // 漫反射
                half halfLambert;
                half3 radiance;
                half3 diffuseLighting = half3(0,0,0);
                #if _FIXERRORNORMAL_ON
                    diffuseLighting = BRDF_HarfLambertLighting_FixN(mainLight, diffCol, N, V, radiance, halfLambert);
                #else
                    diffuseLighting = BRDF_HarfLambertLighting(mainLight, diffCol, N, V, radiance, halfLambert);
                #endif
                finalColor += diffuseLighting * occlusion;

                // 根据世界坐标位置剪裁
                #if _CLIPBYWORLDPOS_ON
                    ClipRole(positionWS.xyz, _ClipWorldPosParam.xyz, _ClipWorldPosParam.w);
                #endif
                
                finalColor = saturate(finalColor);
				return float4(finalColor, 1);
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
            "Queue" = "AlphaTest"
        }
        LOD 100

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            Cull Off

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _HASBASEMAP_ON
            #pragma shader_feature_local_fragment _FIXERRORNORMAL_ON
            #pragma multi_compile_fragment _CLIPBYWORLDPOS_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "BRDF_Cloth.hlsl"

            #if _HASBASEMAP_ON
                TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            #endif

            TEXTURE2D(_FurNoiseMap); SAMPLER(sampler_FurNoiseMap);
            
            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
            half _DiffuseIntensity;

            half _FurNoiseTilling;
            half _FurWindTilling;
            half _FurLen;
            half _FurClip;
            half _FurOcclusion;
            half _FurEdgeFade;

            float4 _ClipWorldPosParam;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normalOS : NORMAL;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings Vertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float3 offsetPos = input.positionOS.xyz + input.normalOS * _FurLen * input.color.r * 0.01;
                output.positionWS = TransformObjectToWorld(offsetPos);
                output.positionCS = TransformWorldToHClip(output.positionWS);
                
                output.uv = input.texcoord;
                output.color = input.color;

                output.normalWS = TransformObjectToWorldNormal(input.normalOS);

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                // TBN
                float3 normalWS = input.normalWS;
                float3 positionWS = input.positionWS;
                half3 N = normalWS;

                // 基本色
                half3 baseColor = _BaseColor.rgb * _DiffuseIntensity;
                #if _HASBASEMAP_ON
                    half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                    baseColor *= baseMap.rgb;
                #endif

                // 毛皮
                half furLayer = input.color.r;
                half furLayerPow2 = Pow2(furLayer);
                half2 uv_furNoise = input.uv * _FurNoiseTilling;
                half4 furNoiseMap = SAMPLE_TEXTURE2D(_FurNoiseMap, sampler_FurNoiseMap, uv_furNoise);
                half furAlpha = furLayer < 0.01 ? 1 : (furNoiseMap.r * 2 - furLayerPow2 * _FurEdgeFade);
                clip(furAlpha - _FurClip); //剪裁
                half occlusion = lerp(_FurOcclusion, 1, furLayer); //毛皮尝试影响ao

                // 准备光照计算数据
                half3 V = GetWorldSpaceNormalizeViewDir(positionWS);
                half3 diffCol = baseColor;
                half3 finalColor = 0;

                // 漫反射
                half3 diffuseLighting = 0;
                #if _FIXERRORNORMAL_ON
                    diffuseLighting = diffCol * (abs(dot(N, V)) * 0.5 + 0.5);
                #else
                    diffuseLighting = diffCol * (dot(N, V) * 0.5 + 0.5);
                #endif
                
                finalColor += diffuseLighting * occlusion;

                // 根据世界坐标位置剪裁
                #if _CLIPBYWORLDPOS_ON
                    ClipRole(positionWS.xyz, _ClipWorldPosParam.xyz, _ClipWorldPosParam.w);
                #endif
                
				return float4(finalColor, 1);
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
            "Queue" = "AlphaTest"
        }
        LOD 50

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            Cull Off

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _HASBASEMAP_ON
            #pragma shader_feature_local_fragment _FIXERRORNORMAL_ON
            #pragma multi_compile_fragment _CLIPBYWORLDPOS_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "BRDF_Cloth.hlsl"

            #if _HASBASEMAP_ON
                TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            #endif

            TEXTURE2D(_FurNoiseMap); SAMPLER(sampler_FurNoiseMap);
            
            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
            half _DiffuseIntensity;

            half _FurNoiseTilling;
            half _FurWindTilling;
            half _FurLen;
            half _FurClip;
            half _FurOcclusion;
            half _FurEdgeFade;

            float4 _ClipWorldPosParam;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normalOS : NORMAL;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings Vertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float3 offsetPos = input.positionOS.xyz + input.normalOS * _FurLen * input.color.r * 0.01;
                output.positionWS = TransformObjectToWorld(offsetPos);
                output.positionCS = TransformWorldToHClip(output.positionWS);
                
                output.uv = input.texcoord;
                output.color = input.color;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                // 基本色
                half3 baseColor = _BaseColor.rgb * _DiffuseIntensity;
                #if _HASBASEMAP_ON
                    half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                    baseColor *= baseMap.rgb;
                #endif

                // 毛皮
                half furLayer = input.color.r;
                half furLayerPow2 = Pow2(furLayer);
                half2 uv_furNoise = input.uv * _FurNoiseTilling;
                half4 furNoiseMap = SAMPLE_TEXTURE2D(_FurNoiseMap, sampler_FurNoiseMap, uv_furNoise);
                half furAlpha = furLayer < 0.01 ? 1 : (furNoiseMap.r * 2 - furLayerPow2 * _FurEdgeFade);
                clip(furAlpha - _FurClip); //剪裁
                //half occlusion = lerp(_FurOcclusion, 1, furLayer); //毛皮尝试影响ao

                // 准备光照计算数据
                half3 diffCol = baseColor;
                half3 finalColor = 0;

                finalColor += diffCol;// * occlusion;

                // 根据世界坐标位置剪裁
                #if _CLIPBYWORLDPOS_ON
                    float3 positionWS = input.positionWS;
                    ClipRole(positionWS.xyz, _ClipWorldPosParam.xyz, _ClipWorldPosParam.w);
                #endif
                
				return float4(finalColor, 1);
            }
            
            ENDHLSL
        }
    }
    
    FallBack "Hidden/Universal Render Pipeline/FallbackError"

    CustomEditor "TATools.SimpleShaderGUI"


}
