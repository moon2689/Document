Shader "TA/Role/Low/Common_Skin_FaceDress"
{
    Properties
    {
        // 眼球------------------------------------------------------------>
        [Foldout(1,2,0,0)]
        _FoldoutEyeball("眼球_Foldout", float) = 1

        [Tex] [NoScaleOffset] _EyeballMap ("眼球贴图", 2D) = "black" { }

        [Toggle_Switch] _DiffrentEyeball("不同的眼球", float) = 0
        [Tex(_DiffrentEyeball)] [NoScaleOffset] _EyeballMap2 ("眼球贴图二", 2D) = "black" { }

        _ScleraColor ("眼白颜色", Color) = (1, 1, 1, 1)
        _PupilColor ("瞳孔颜色", Color) = (1, 1, 1, 1)
        _EyeballScale ("眼球缩放", Range(0, 1)) = 0.44
        _EyeParallax ("眼睛视差偏移", Range(0, 1)) = 0.3
        _EyeSpecularIntensity ("眼睛高光强度", Range(0, 1)) = 0.5
        _RightEyeSpecularOffset ("右眼高光偏移", float) = 0
        _RoughnessSclera ("眼白粗糙度", Range(0.05, 1)) = 1
        _RoughnessEyeball ("眼球粗糙度", Range(0.05, 1)) = 0.2
        _EyeShadowStartY ("眼睛阴影开始V坐标", Range(0, 1)) = 1
        _EyeShadowEndY ("眼睛阴影结束V坐标", Range(0, 1)) = 0.3
        
        [Foldout_Out(1)]
        _FoldoutOutEyeball("眼球_Foldout", float) = 1
        // 眼球<------------------------------------------------------------

        // 眉毛------------------------------------------------------------>
        [Foldout(1,2,0,0)]
        _FoldoutEyebrow("眉毛_Foldout", float) = 1

        [Tex] _EyebrowMap ("眉毛贴图", 2D) = "black" { }
        _EyebrowColor ("眉毛颜色", Color) = (0, 0, 0, 1)

        [Foldout_Out(1)]
        _FoldoutOutEyebrow("眉毛_Foldout", float) = 1
        // 眉毛<------------------------------------------------------------

        // 眼影------------------------------------------------------------>
        [Foldout(1,2,0,0)]
        _FoldoutEyeshadow("眼影_Foldout", float) = 1

        [Tex] [NoScaleOffset] _EyeshadowMap ("眼影贴图", 2D) = "black" { }
        _EyeshadowColor ("眼影颜色", Color) = (0, 0, 0, 1)

        [Foldout_Out(1)]
        _FoldoutOutEyeshadow("眼影_Foldout", float) = 1
        // 眼影<------------------------------------------------------------

        // 眼线------------------------------------------------------------>
        [Foldout(1,2,0,0)]
        _FoldoutEyeliner("眼线_Foldout", float) = 1

        [Tex] [NoScaleOffset] _EyelinerMap ("眼线贴图", 2D) = "black" { }
        _EyelinerColor ("眼线颜色", Color) = (1, 1, 1, 1)

        [Foldout_Out(1)]
        _FoldoutOutEyeliner("眼线_Foldout", float) = 1
        // 眼线<------------------------------------------------------------

        // 睫毛------------------------------------------------------------>
        [Foldout(1,2,0,0)]
        _FoldoutEyelash("睫毛_Foldout", float) = 1

        [Tex] [NoScaleOffset] _EyelashMap ("睫毛贴图", 2D) = "black" { }
        _EyelashColor ("睫毛颜色", Color) = (0, 0, 0, 1)

        [Foldout_Out(1)]
        _FoldoutOutEyelash("睫毛_Foldout", float) = 1
        // 睫毛<------------------------------------------------------------

        // 嘴唇------------------------------------------------------------>
        [Foldout(1,2,0,0)]
        _FoldoutLip("嘴唇_Foldout", float) = 1

        // 嘴唇
        [Tex] [NoScaleOffset] _LipglossMap ("嘴唇贴图", 2D) = "black" { }
        [Tex] [NoScaleOffset] _LipglossNormalMap ("嘴唇法线", 2D) = "bump" { }
        _LipglossColor ("嘴唇颜色", Color) = (1, 0, 0, 1)
        _LipglossBlendColor ("嘴唇调和颜色", Color) = (1, 0, 0, 1)
        _LipglossSpecularIntensity ("嘴唇高光强度", Range(0, 1)) = 0.5
        _RoughnessLipgloss ("嘴唇粗糙度", Range(0.05, 1)) = 0.2

        [Foldout_Out(1)]
        _FoldoutOutLip("嘴唇_Foldout", float) = 1
        // 嘴唇<------------------------------------------------------------

        // 胡子------------------------------------------------------------>
        [Foldout(1,2,0,0)]
        _FoldoutBeard("胡子_Foldout", float) = 1
        [Tex] [NoScaleOffset] _BeardMap ("胡子贴图", 2D) = "black" { }
        [Foldout_Out(1)]
        _FoldoutOutBeard("胡子_Foldout", float) = 1
        // 胡子<------------------------------------------------------------
        
        [Toggle_Switch] _ClipByWorldPos("是否根据世界坐标剪裁", float) = 0
        _ClipWorldPosParam("剪裁世界坐标位置中心与半径", Vector) = (0,0,0,1)
    }


    SubShader
    {
        Tags
        {   "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent"
        }
        LOD 500

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            Blend One OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile_fragment _ _DIFFRENTEYEBALL_ON
            #pragma multi_compile_fragment _CLIPBYWORLDPOS_ON

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

            #include "BRDF_Skin.hlsl"

            TEXTURE2D(_EyeballMap); SAMPLER(sampler_EyeballMap);
            TEXTURE2D(_EyebrowMap); SAMPLER(sampler_EyebrowMap);
            TEXTURE2D(_EyeshadowMap); SAMPLER(sampler_EyeshadowMap);
            TEXTURE2D(_EyelinerMap); SAMPLER(sampler_EyelinerMap);
            TEXTURE2D(_EyelashMap); SAMPLER(sampler_EyelashMap);
            TEXTURE2D(_LipglossMap); SAMPLER(sampler_LipglossMap);
            TEXTURE2D(_LipglossNormalMap); SAMPLER(sampler_LipglossNormalMap);
            TEXTURE2D(_BeardMap); SAMPLER(sampler_BeardMap);

            #if _DIFFRENTEYEBALL_ON
                TEXTURE2D(_EyeballMap2); SAMPLER(sampler_EyeballMap2);
            #endif

            CBUFFER_START(UnityPerMaterial)
            half4 _ScleraColor;
            half4 _PupilColor;
            half _EyeballScale;
            half _EyeParallax;
            half _EyeSpecularIntensity;
            half _RightEyeSpecularOffset;
            half _RoughnessSclera;
            half _RoughnessEyeball;
            half _EyeShadowStartY;
            half _EyeShadowEndY;

            half4 _EyeshadowColor;
            
            half4 _EyebrowMap_ST;
            half4 _EyebrowColor;
            half4 _EyelashColor;
            half4 _EyelinerColor;
            
            half4 _LipglossColor;
            half4 _LipglossBlendColor;
            half _LipglossSpecularIntensity;
            half _RoughnessLipgloss;

            half _LowSkinLightIntensity;

            float4 _ClipWorldPosParam;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 color : COLOR;
                float4 tangentOS : TANGENT;
                float3 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
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
                
                output.color = input.color;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                // get info
                float3 tangentWS = input.tangentWS.xyz;
                float3 bitangentWS = input.bitangentWS.xyz;
                float3 normalWS = input.normalWS.xyz;
                float3 positionWS = float3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
                float3x3 TBN = float3x3(tangentWS, bitangentWS, normalWS);
                
                // get light
                half3 N = normalWS;
                half3 V = GetWorldSpaceNormalizeViewDir(positionWS);
                Light mainLight = GetMainLight_ta(positionWS);
                half3 L = -GetViewForwardDir(); // 取摄像机前方方向作为光源方向
                half NoV = saturate(abs(dot(N, V)) + 1e-5);
                
                half3 baseColor = half3(0, 0, 0);
                half alpha = 0;
                half roughness = 1;
                half specIntensity = 0.04;

                // 遮罩
                float mask = input.color.r;
                half maskEyeballLeft = step(0.05, mask) * step(mask, 0.15); // 眼球 左
                half maskEyeballRight = step(0.15, mask) * step(mask, 0.25); // 眼球 右
                half maskEyeball = max(maskEyeballLeft, maskEyeballRight); // 眼球

                half maskEyebrow = step(0.25, mask) * step(mask, 0.35); // 眉毛
                half maskEyeshadow = step(0.35, mask) * step(mask, 0.45); // 眼影
                half maskEyelash = step(0.45, mask) * step(mask, 0.55); // 睫毛
                half maskLipgloss = step(0.55, mask) * step(mask, 0.65); // 嘴唇
                half maskBeard = step(0.65, mask) * step(mask, 0.75); // 胡子

                // 眼球
                half2 uv = input.uv;
                half2 uv_eyeballMap = GetEyeballUV(uv, _EyeballScale, V, TBN, _EyeParallax); // 带视察偏移和缩放的uv
                
                #if _DIFFRENTEYEBALL_ON
                    half4 eyeballMapRight = SAMPLE_TEXTURE2D(_EyeballMap, sampler_EyeballMap, uv_eyeballMap);
                    half4 eyeballMapLeft = SAMPLE_TEXTURE2D(_EyeballMap2, sampler_EyeballMap2, uv_eyeballMap);
                    half maskPupilLeft = eyeballMapLeft.a * maskEyeballLeft;
                    half maskPupilRight = eyeballMapRight.a * maskEyeballRight;
                    half maskPupil = max(maskPupilLeft, maskPupilRight);
                    half3 baseColorEyeball = lerp(_ScleraColor.rgb, eyeballMapLeft.rgb * _PupilColor.rgb, maskPupilLeft);
                    baseColorEyeball = lerp(baseColorEyeball, eyeballMapRight.rgb * _PupilColor.rgb, maskPupilRight);
                #else
                    half4 eyeballMap = SAMPLE_TEXTURE2D(_EyeballMap, sampler_EyeballMap, uv_eyeballMap);
                    half maskPupil = eyeballMap.a * maskEyeball;
                    half maskPupilRight = eyeballMap.a * maskEyeballRight;
                    half3 baseColorEyeball = lerp(_ScleraColor.rgb, eyeballMap.rgb * _PupilColor.rgb, maskPupil);
                #endif

                L = lerp(L, RotateAroundByRadian(_RightEyeSpecularOffset, L), maskPupilRight); // 右眼高光偏移一下，避免高光出现斗鸡眼的情况

                alpha = lerp(alpha, 1, maskEyeball);
                half roughnessEyeball= lerp(_RoughnessSclera, _RoughnessEyeball, maskPupil);
                roughness = lerp(roughness, roughnessEyeball, maskEyeball);
                specIntensity = lerp(specIntensity, _EyeSpecularIntensity, maskEyeball);

                // 眼睛阴影
                half vOffset = _EyeballScale * (uv.x < 0.5 ? uv.x : (1 - uv.x));
                half shadowMask = smoothstep(_EyeShadowStartY + vOffset, _EyeShadowEndY + vOffset, uv.y);
                baseColorEyeball *= shadowMask;
                baseColor = lerp(baseColor, baseColorEyeball, maskEyeball);

                // 眉毛
                half2 uv_eyebrowMap = uv * _EyebrowMap_ST.xy + _EyebrowMap_ST.zw;
                half4 eyebrowMap = SAMPLE_TEXTURE2D(_EyebrowMap, sampler_EyebrowMap, uv_eyebrowMap);
                alpha = lerp(alpha, eyebrowMap.a, maskEyebrow);
                baseColor = lerp(baseColor, _EyebrowColor.rgb, maskEyebrow);

                // 眼影
                half4 eyeshadowMap = SAMPLE_TEXTURE2D(_EyeshadowMap, sampler_EyeshadowMap, uv);
                half4 eyelinerMap = SAMPLE_TEXTURE2D(_EyelinerMap, sampler_EyelinerMap, uv);
                half3 baseColorEyeshadow = lerp(eyeshadowMap.rgb * _EyeshadowColor.rgb, _EyelinerColor.rgb, eyelinerMap.a);
                half alphaEyeshadow = lerp(eyeshadowMap.a, eyelinerMap.a, eyelinerMap.a);
                baseColor = lerp(baseColor, baseColorEyeshadow, maskEyeshadow);
                alpha = lerp(alpha, alphaEyeshadow, maskEyeshadow);

                /*
                // 眼影法线
                half4 normalMapEyeshadow = SAMPLE_TEXTURE2D(_EyeshadowNormalMap, sampler_EyeshadowNormalMap, uv);
                half3 N_Eyeshadow = TransformTangentToWorld(UnpackNormal(normalMapEyeshadow), TBN);
                N = lerp(N, N_Eyeshadow, maskEyeshadow);
                */

                // 睫毛
                half4 eyelashMap = SAMPLE_TEXTURE2D(_EyelashMap, sampler_EyelashMap, uv);
                baseColor = lerp(baseColor, _EyelashColor.rgb, maskEyelash);
                alpha = lerp(alpha, eyelashMap.a, maskEyelash);

                // 嘴唇
                half4 lipglossMap = SAMPLE_TEXTURE2D(_LipglossMap, sampler_LipglossMap, uv);
                baseColor = lerp(baseColor, 10 * _LipglossBlendColor.a * _LipglossBlendColor.rgb * _LipglossColor.rgb, maskLipgloss);
                alpha = lerp(alpha, lipglossMap.a, maskLipgloss);
                    
                // 嘴唇法线
                half4 normalMapLipgloss = SAMPLE_TEXTURE2D(_LipglossNormalMap, sampler_LipglossNormalMap, uv);
                half3 N_Lipgloss = TransformTangentToWorld(UnpackNormal(normalMapLipgloss), TBN);
                N = lerp(N, N_Lipgloss, maskLipgloss);

                specIntensity = lerp(specIntensity, _LipglossSpecularIntensity, maskLipgloss);
                half roughnessLipgloss = lerp(roughness, _RoughnessLipgloss, alpha);
                roughness = lerp(roughness, roughnessLipgloss, maskLipgloss);

                // 胡子
                half4 beardMap = SAMPLE_TEXTURE2D(_BeardMap, sampler_BeardMap, uv);
                baseColor = lerp(baseColor, beardMap.rgb, maskBeard);
                alpha = lerp(alpha, beardMap.a, maskBeard);

                // 光照计算
                half3 diffCol = baseColor;
                half3 specCol = specIntensity.xxx;
                half3 finalColor = half3(0, 0, 0);

                half3 dirLighting = DirectorLighting_HeadDress(mainLight, diffCol, specCol, N, L, V, NoV, roughness);
                finalColor += dirLighting;

                //half3 indirectLighting = IndirectLighting_Custom(diffCol, specCol, N, V, NoV, roughness, _EnvCube, sampler_EnvCube, _EnvCube_HDR, _EnvRotateAngle, _EnvAO);
                //pbrLighting += indirectLighting;

                /*
                // matcap
                half3 viewN = mul(UNITY_MATRIX_V, float4(N, 0)).xyz;
                half2 uv_matcap = viewN.xy * 0.5 + float2(0.5, 0.5);
                half4 matcapColor = SAMPLE_TEXTURE2D(_EyeEnvMatcap, sampler_EyeEnvMatcap, uv_matcap);
                pbrLighting += matcapColor.rgb;
                */

                // 根据世界坐标位置剪裁
                #if _CLIPBYWORLDPOS_ON
                    ClipRole(positionWS.xyz, _ClipWorldPosParam.xyz, _ClipWorldPosParam.w);
                #endif

                finalColor *= alpha;
                finalColor = saturate(finalColor);
                return half4(finalColor, alpha);
            }
            
            ENDHLSL
        }
    }

    
    SubShader
    {
        Tags
        {   "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent"
        }
        LOD 300

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            Blend One OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile_fragment _ _DIFFRENTEYEBALL_ON
            #pragma multi_compile_fragment _CLIPBYWORLDPOS_ON

            // -------------------------------------
            // Universal Pipeline keywords
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
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

            #include "BRDF_Skin.hlsl"

            TEXTURE2D(_EyeballMap); SAMPLER(sampler_EyeballMap);
            TEXTURE2D(_EyebrowMap); SAMPLER(sampler_EyebrowMap);
            TEXTURE2D(_EyeshadowMap); SAMPLER(sampler_EyeshadowMap);
            TEXTURE2D(_EyelinerMap); SAMPLER(sampler_EyelinerMap);
            TEXTURE2D(_EyelashMap); SAMPLER(sampler_EyelashMap);
            TEXTURE2D(_LipglossMap); SAMPLER(sampler_LipglossMap);
            TEXTURE2D(_LipglossNormalMap); SAMPLER(sampler_LipglossNormalMap);
            TEXTURE2D(_BeardMap); SAMPLER(sampler_BeardMap);

            #if _DIFFRENTEYEBALL_ON
                TEXTURE2D(_EyeballMap2); SAMPLER(sampler_EyeballMap2);
            #endif

            CBUFFER_START(UnityPerMaterial)
            half4 _ScleraColor;
            half4 _PupilColor;
            half _EyeballScale;
            half _EyeParallax;
            half _EyeSpecularIntensity;
            half _RightEyeSpecularOffset;
            half _RoughnessSclera;
            half _RoughnessEyeball;
            half _EyeShadowStartY;
            half _EyeShadowEndY;

            half4 _EyeshadowColor;
            
            half4 _EyebrowMap_ST;
            half4 _EyebrowColor;
            half4 _EyelashColor;
            half4 _EyelinerColor;
            
            half4 _LipglossColor;
            half4 _LipglossBlendColor;
            half _LipglossSpecularIntensity;
            half _RoughnessLipgloss;

            half _LowSkinLightIntensity;

            float4 _ClipWorldPosParam;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 color : COLOR;
                float4 tangentOS : TANGENT;
                float3 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
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
                
                output.color = input.color;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                // get info
                float3 tangentWS = input.tangentWS.xyz;
                float3 bitangentWS = input.bitangentWS.xyz;
                float3 normalWS = input.normalWS.xyz;
                float3 positionWS = float3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
                float3x3 TBN = float3x3(tangentWS, bitangentWS, normalWS);
                
                // get light
                half3 N = normalWS;
                half3 V = GetWorldSpaceNormalizeViewDir(positionWS);
                Light mainLight = GetMainLight_ta(positionWS);
                half3 L = -GetViewForwardDir(); // 取摄像机前方方向作为光源方向
                //half NoV = saturate(abs(dot(N, V)) + 1e-5);
                
                half3 baseColor = half3(0, 0, 0);
                half alpha = 0;
                //half roughness = 1;
                half specIntensity = 0.04;

                // 遮罩
                float mask = input.color.r;
                half maskEyeballLeft = step(0.05, mask) * step(mask, 0.15); // 眼球 左
                half maskEyeballRight = step(0.15, mask) * step(mask, 0.25); // 眼球 右
                half maskEyeball = max(maskEyeballLeft, maskEyeballRight); // 眼球

                half maskEyebrow = step(0.25, mask) * step(mask, 0.35); // 眉毛
                half maskEyeshadow = step(0.35, mask) * step(mask, 0.45); // 眼影
                half maskEyelash = step(0.45, mask) * step(mask, 0.55); // 睫毛
                half maskLipgloss = step(0.55, mask) * step(mask, 0.65); // 嘴唇
                half maskBeard = step(0.65, mask) * step(mask, 0.75); // 胡子

                // 眼球
                half2 uv = input.uv;
                //half2 uv_eyeballMap = GetEyeballUV(uv, _EyeballScale, V, TBN, _EyeParallax); // 带视察偏移和缩放的uv
                half2 uv_eyeballMap = ScaleUVsByCenter(uv, _EyeballScale);
                
                #if _DIFFRENTEYEBALL_ON
                    half4 eyeballMapRight = SAMPLE_TEXTURE2D(_EyeballMap, sampler_EyeballMap, uv_eyeballMap);
                    half4 eyeballMapLeft = SAMPLE_TEXTURE2D(_EyeballMap2, sampler_EyeballMap2, uv_eyeballMap);
                    half maskPupilLeft = eyeballMapLeft.a * maskEyeballLeft;
                    half maskPupilRight = eyeballMapRight.a * maskEyeballRight;
                    half maskPupil = max(maskPupilLeft, maskPupilRight);
                    half3 baseColorEyeball = lerp(_ScleraColor.rgb, eyeballMapLeft.rgb * _PupilColor.rgb, maskPupilLeft);
                    baseColorEyeball = lerp(baseColorEyeball, eyeballMapRight.rgb * _PupilColor.rgb, maskPupilRight);
                #else
                    half4 eyeballMap = SAMPLE_TEXTURE2D(_EyeballMap, sampler_EyeballMap, uv_eyeballMap);
                    half maskPupil = eyeballMap.a * maskEyeball;
                    half maskPupilRight = eyeballMap.a * maskEyeballRight;
                    half3 baseColorEyeball = lerp(_ScleraColor.rgb, eyeballMap.rgb * _PupilColor.rgb, maskPupil);
                #endif

                //L = lerp(L, RotateAroundByRadian(_RightEyeSpecularOffset, L), maskPupilRight); // 右眼高光偏移一下，避免高光出现斗鸡眼的情况

                alpha = lerp(alpha, 1, maskEyeball);
                //half roughnessEyeball= lerp(_RoughnessSclera, _RoughnessEyeball, maskPupil);
                //roughness = lerp(roughness, roughnessEyeball, maskEyeball);
                //specIntensity = lerp(specIntensity, _EyeSpecularIntensity, maskEyeball);

                // 眼睛阴影
                half vOffset = _EyeballScale * (uv.x < 0.5 ? uv.x : (1 - uv.x));
                half shadowMask = smoothstep(_EyeShadowStartY + vOffset, _EyeShadowEndY + vOffset, uv.y);
                baseColorEyeball *= shadowMask;
                baseColor = lerp(baseColor, baseColorEyeball, maskEyeball);

                // 眉毛
                half2 uv_eyebrowMap = uv * _EyebrowMap_ST.xy + _EyebrowMap_ST.zw;
                half4 eyebrowMap = SAMPLE_TEXTURE2D(_EyebrowMap, sampler_EyebrowMap, uv_eyebrowMap);
                alpha = lerp(alpha, eyebrowMap.a, maskEyebrow);
                baseColor = lerp(baseColor, _EyebrowColor.rgb, maskEyebrow);

                // 眼影
                half4 eyeshadowMap = SAMPLE_TEXTURE2D(_EyeshadowMap, sampler_EyeshadowMap, uv);
                half4 eyelinerMap = SAMPLE_TEXTURE2D(_EyelinerMap, sampler_EyelinerMap, uv);
                half3 baseColorEyeshadow = lerp(eyeshadowMap.rgb * _EyeshadowColor.rgb, _EyelinerColor.rgb, eyelinerMap.a);
                half alphaEyeshadow = lerp(eyeshadowMap.a, eyelinerMap.a, eyelinerMap.a);
                baseColor = lerp(baseColor, baseColorEyeshadow, maskEyeshadow);
                alpha = lerp(alpha, alphaEyeshadow, maskEyeshadow);

                /*
                // 眼影法线
                half4 normalMapEyeshadow = SAMPLE_TEXTURE2D(_EyeshadowNormalMap, sampler_EyeshadowNormalMap, uv);
                half3 N_Eyeshadow = TransformTangentToWorld(UnpackNormal(normalMapEyeshadow), TBN);
                N = lerp(N, N_Eyeshadow, maskEyeshadow);
                */

                // 睫毛
                half4 eyelashMap = SAMPLE_TEXTURE2D(_EyelashMap, sampler_EyelashMap, uv);
                baseColor = lerp(baseColor, _EyelashColor.rgb, maskEyelash);
                alpha = lerp(alpha, eyelashMap.a, maskEyelash);

                // 嘴唇
                half4 lipglossMap = SAMPLE_TEXTURE2D(_LipglossMap, sampler_LipglossMap, uv);
                baseColor = lerp(baseColor, 10 * _LipglossBlendColor.a * _LipglossBlendColor.rgb * _LipglossColor.rgb, maskLipgloss);
                alpha = lerp(alpha, lipglossMap.a, maskLipgloss);

                // 嘴唇法线
                half4 normalMapLipgloss = SAMPLE_TEXTURE2D(_LipglossNormalMap, sampler_LipglossNormalMap, uv);
                half3 N_Lipgloss = TransformTangentToWorld(UnpackNormal(normalMapLipgloss), TBN);
                N = lerp(N, N_Lipgloss, maskLipgloss);

                specIntensity = lerp(specIntensity, _LipglossSpecularIntensity, maskLipgloss);
                //half roughnessLipgloss = lerp(roughness, _RoughnessLipgloss, alpha);
                //roughness = lerp(roughness, roughnessLipgloss, maskLipgloss);

                // 胡子
                half4 beardMap = SAMPLE_TEXTURE2D(_BeardMap, sampler_BeardMap, uv);
                baseColor = lerp(baseColor, beardMap.rgb, maskBeard);
                alpha = lerp(alpha, beardMap.a, maskBeard);

                // 光照计算
                half3 diffCol = baseColor;
                half3 specCol = specIntensity.xxx;
                half3 finalColor = 0;

                //half3 dirLighting = DirectorLighting_HeadDress(mainLight, diffCol, specCol, N, L, V, NoV, roughness);
                //finalColor += dirLighting;
                
                // diffuse
                half NoL = dot(N, L);
                half3 diffLighting = diffCol * (NoL * 0.5 + 0.5) * mainLight.color; 
                finalColor += diffLighting;

                // specular
                half3 finalSpec = BlinnPhong_SpecularSkin(specCol, N, L, V);
                finalColor += finalSpec;
                
                // env
                half3 envLighting = DiffuseIndirect(diffCol, N);
                finalColor += envLighting;
                
                //finalColor += dirLighting;

                //half3 indirectLighting = IndirectLighting_Custom(diffCol, specCol, N, V, NoV, roughness, _EnvCube, sampler_EnvCube, _EnvCube_HDR, _EnvRotateAngle, _EnvAO);
                //pbrLighting += indirectLighting;

                /*
                // matcap
                half3 viewN = mul(UNITY_MATRIX_V, float4(N, 0)).xyz;
                half2 uv_matcap = viewN.xy * 0.5 + float2(0.5, 0.5);
                half4 matcapColor = SAMPLE_TEXTURE2D(_EyeEnvMatcap, sampler_EyeEnvMatcap, uv_matcap);
                pbrLighting += matcapColor.rgb;
                */

                // 根据世界坐标位置剪裁
                #if _CLIPBYWORLDPOS_ON
                    ClipRole(positionWS.xyz, _ClipWorldPosParam.xyz, _ClipWorldPosParam.w);
                #endif

                finalColor *= alpha;
                finalColor = saturate(finalColor);
                return half4(finalColor, alpha);
            }
            
            ENDHLSL
        }
    }

    
    SubShader
    {
        Tags
        {   "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent"
        }
        LOD 50

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            Blend One OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile_fragment _ _DIFFRENTEYEBALL_ON
            #pragma multi_compile_fragment _CLIPBYWORLDPOS_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "BRDF_Skin.hlsl"

            TEXTURE2D(_EyeballMap); SAMPLER(sampler_EyeballMap);
            TEXTURE2D(_EyebrowMap); SAMPLER(sampler_EyebrowMap);
            TEXTURE2D(_EyeshadowMap); SAMPLER(sampler_EyeshadowMap);
            TEXTURE2D(_EyelinerMap); SAMPLER(sampler_EyelinerMap);
            TEXTURE2D(_EyelashMap); SAMPLER(sampler_EyelashMap);
            TEXTURE2D(_LipglossMap); SAMPLER(sampler_LipglossMap);
            TEXTURE2D(_BeardMap); SAMPLER(sampler_BeardMap);

            #if _DIFFRENTEYEBALL_ON
                TEXTURE2D(_EyeballMap2); SAMPLER(sampler_EyeballMap2);
            #endif

            CBUFFER_START(UnityPerMaterial)
            half4 _ScleraColor;
            half4 _PupilColor;
            half _EyeballScale;
            half _EyeParallax;
            half _EyeSpecularIntensity;
            half _RightEyeSpecularOffset;
            half _RoughnessSclera;
            half _RoughnessEyeball;
            half _EyeShadowStartY;
            half _EyeShadowEndY;

            half4 _EyeshadowColor;
            
            half4 _EyebrowMap_ST;
            half4 _EyebrowColor;
            half4 _EyelashColor;
            half4 _EyelinerColor;
            
            half4 _LipglossColor;
            half4 _LipglossBlendColor;
            half _LipglossSpecularIntensity;
            half _RoughnessLipgloss;

            float4 _ClipWorldPosParam;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 color : COLOR;
                float3 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float3 normalWS : TEXCOORD2;
                float3 positionWS : TEXCOORD3;
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
                output.color = input.color;
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                float3 normalWS = input.normalWS;
                float3 positionWS = input.positionWS;
                
                // get light
                half3 N = normalWS;
                Light mainLight = GetMainLight();//GetMainLight_ta(positionWS);
                half3 L = -GetViewForwardDir(); // 取摄像机前方方向作为光源方向
                
                half3 baseColor = 0;
                half alpha = 0;

                // 遮罩
                float mask = input.color.r;
                half maskEyeballLeft = step(0.05, mask) * step(mask, 0.15); // 眼球 左
                half maskEyeballRight = step(0.15, mask) * step(mask, 0.25); // 眼球 右
                half maskEyeball = max(maskEyeballLeft, maskEyeballRight); // 眼球

                half maskEyebrow = step(0.25, mask) * step(mask, 0.35); // 眉毛
                half maskEyeshadow = step(0.35, mask) * step(mask, 0.45); // 眼影
                half maskEyelash = step(0.45, mask) * step(mask, 0.55); // 睫毛
                half maskLipgloss = step(0.55, mask) * step(mask, 0.65); // 嘴唇
                half maskBeard = step(0.65, mask) * step(mask, 0.75); // 胡子

                // 眼球
                half2 uv = input.uv;
                half2 uv_eyeballMap = ScaleUVsByCenter(uv, _EyeballScale);
                
                #if _DIFFRENTEYEBALL_ON
                    half4 eyeballMapRight = SAMPLE_TEXTURE2D(_EyeballMap, sampler_EyeballMap, uv_eyeballMap);
                    half4 eyeballMapLeft = SAMPLE_TEXTURE2D(_EyeballMap2, sampler_EyeballMap2, uv_eyeballMap);
                    half maskPupilLeft = eyeballMapLeft.a * maskEyeballLeft;
                    half maskPupilRight = eyeballMapRight.a * maskEyeballRight;
                    half maskPupil = max(maskPupilLeft, maskPupilRight);
                    half3 baseColorEyeball = lerp(_ScleraColor.rgb, eyeballMapLeft.rgb * _PupilColor.rgb, maskPupilLeft);
                    baseColorEyeball = lerp(baseColorEyeball, eyeballMapRight.rgb * _PupilColor.rgb, maskPupilRight);
                #else
                    half4 eyeballMap = SAMPLE_TEXTURE2D(_EyeballMap, sampler_EyeballMap, uv_eyeballMap);
                    half maskPupil = eyeballMap.a * maskEyeball;
                    half3 baseColorEyeball = lerp(_ScleraColor.rgb, eyeballMap.rgb * _PupilColor.rgb, maskPupil);
                #endif

                alpha = lerp(alpha, 1, maskEyeball);

                // 眼睛阴影
                half vOffset = _EyeballScale * (uv.x < 0.5 ? uv.x : (1 - uv.x));
                half shadowMask = smoothstep(_EyeShadowStartY + vOffset, _EyeShadowEndY + vOffset, uv.y);
                baseColorEyeball *= shadowMask;
                baseColor = lerp(baseColor, baseColorEyeball, maskEyeball);

                // 眉毛
                half2 uv_eyebrowMap = uv * _EyebrowMap_ST.xy + _EyebrowMap_ST.zw;
                half4 eyebrowMap = SAMPLE_TEXTURE2D(_EyebrowMap, sampler_EyebrowMap, uv_eyebrowMap);
                alpha = lerp(alpha, eyebrowMap.a, maskEyebrow);
                baseColor = lerp(baseColor, _EyebrowColor.rgb, maskEyebrow);

                // 眼影
                half4 eyeshadowMap = SAMPLE_TEXTURE2D(_EyeshadowMap, sampler_EyeshadowMap, uv);
                half4 eyelinerMap = SAMPLE_TEXTURE2D(_EyelinerMap, sampler_EyelinerMap, uv);
                half3 baseColorEyeshadow = lerp(eyeshadowMap.rgb * _EyeshadowColor.rgb, _EyelinerColor.rgb, eyelinerMap.a);
                half alphaEyeshadow = lerp(eyeshadowMap.a, eyelinerMap.a, eyelinerMap.a);
                baseColor = lerp(baseColor, baseColorEyeshadow, maskEyeshadow);
                alpha = lerp(alpha, alphaEyeshadow, maskEyeshadow);

                // 睫毛
                half4 eyelashMap = SAMPLE_TEXTURE2D(_EyelashMap, sampler_EyelashMap, uv);
                baseColor = lerp(baseColor, _EyelashColor.rgb, maskEyelash);
                alpha = lerp(alpha, eyelashMap.a, maskEyelash);

                // 嘴唇
                half4 lipglossMap = SAMPLE_TEXTURE2D(_LipglossMap, sampler_LipglossMap, uv);
                baseColor = lerp(baseColor, 10 * _LipglossBlendColor.a * _LipglossBlendColor.rgb * _LipglossColor.rgb, maskLipgloss);
                alpha = lerp(alpha, lipglossMap.a, maskLipgloss);

                // 胡子
                half4 beardMap = SAMPLE_TEXTURE2D(_BeardMap, sampler_BeardMap, uv);
                baseColor = lerp(baseColor, beardMap.rgb, maskBeard);
                alpha = lerp(alpha, beardMap.a, maskBeard);

                // 光照计算
                half3 diffCol = baseColor;
                half3 finalColor = 0;
                
                // diffuse
                half NoL = dot(N, L);
                half3 diffLighting = diffCol * (NoL * 0.5 + 0.5) * mainLight.color; 
                finalColor += diffLighting;
                
                // env
                half3 envLighting = DiffuseIndirect(diffCol, N);
                finalColor += envLighting;
               

                // 根据世界坐标位置剪裁
                #if _CLIPBYWORLDPOS_ON
                    ClipRole(positionWS.xyz, _ClipWorldPosParam.xyz, _ClipWorldPosParam.w);
                #endif

                finalColor *= alpha;
                return half4(finalColor, alpha);
            }
            
            ENDHLSL
        }
    }

    
    FallBack "Hidden/Universal Render Pipeline/FallbackError"

    CustomEditor "TATools.SimpleShaderGUI"

}