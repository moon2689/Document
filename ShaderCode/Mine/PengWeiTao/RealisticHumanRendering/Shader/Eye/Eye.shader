Shader "RealHuman/Eye"
{
    Properties
    {
         [Toggle]_EnableEyeScale("Enable Eye Scale",Float) =1
         _EyeScale("Enable Eye Scale",Float) =0.018
        _MainTex ("Base Map", 2D)               = "White"{}
        _EyeMaskMap ("Eye Mask Map", 2D)        = "White"{}
        _NormalScale("Normal Scale",Range(0,10)) = 1
        _NormalMap("Normal Map",2D)             = "Black"{}
        _ReflectionCube("Reflection Cube",Cube) = "Black"{}
        _ReflectionCubeRot(" Reflection Cube Rot",Range(0,3.14)) = 0
        _ReflectionVec("Reflection x:Pow y:Scale",Vector)=(1,1,0,0)
        _Rougness_NormalSpecular("(Sclera巩膜眼白)Roughness Normal Specular",Range(0,1)) = 0.1
        _Rougness_NormalSpecularIntensity("(Sclera巩膜眼白)Roughness Normal Specular Intensity",Range(0,30)) = 1
        
        [Space(15)]
        _Roughness("(Iris+Pupil虹膜 瞳孔)_Roughness",Range(0,1)) = 1
        _SpecularIntensity("(Iris+Pupil虹膜 瞳孔)Specular Intensity",Range(0,1)) = 1
        
        [Space(15)]
        [Toggle]_EnableEyeAO("Enable Eye AO",Float) =1
        [Toggle]_EnableDazEye("Enale Daz Eye AO",Float) = 0
        _AOMin("AO Min",Range(0,1)) = 0
        _AOMax("AO Max",Range(0,1)) = 1
        
        [Space(15)]
        [Toggle(DISAPLE_SPECULAR)]_DisableSpecular("Disable Specular",Float) =0
        [Toggle(ONLY_SPECULAR)]_OnlySpecular("Only Specular",Float) =0
        
        [Toggle(ENABLE_DISCARD_ON)]_EnableDiscardOn("Dsicard?",Float) =0
        
        
        [Space(15)]
        [Header(Blend Mode)]
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendMode("Src Blend Mode", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendMode("Dst Blend Mode", Float) = 0
//        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOP("BlendOp Mode", Float) = 0

        [Header(Depth Mode)]
        [Enum(Off, 0, On, 1)] _Zwrite("ZWrite Mode", Float) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _Ztest("ZTest Mode", Float) = 4
        
        _MinBrightness("Min Brightness",Range(0,1)) = 0
    }
    SubShader
    {
     	Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "Lit" "IgnoreProjector" = "True" "ShaderModel"="4.5"
        }
        LOD 300

        Pass
        {
            Tags{"LightMode"="UniversalForward"}
            
            ZWrite[_Zwrite]
            ZTest[_Ztest]
            Blend[_SrcBlendMode][_DstBlendMode]
            
            HLSLPROGRAM
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            
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
            #pragma multi_compile _ _CLUSTERED_RENDERING
            
            #pragma shader_feature _ DISAPLE_SPECULAR
            #pragma shader_feature _ ONLY_SPECULAR
            #pragma shader_feature _ ENABLE_DISCARD_ON
            #pragma multi_compile _ ENABLE_RAYTRACING_REFRACT
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #include "../Common/TABRDF.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float4 tangentWS : TEXCOORD3; 
                float3 bitangentWS : TEXCOORD4;
                float4 screenPos : TEXCOORD5;
            };

            TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);
            TEXTURE2D(_EyeMaskMap);SAMPLER(sampler_EyeMaskMap);
            TEXTURE2D(_NormalMap);SAMPLER(sampler_NormalMap);
            TEXTURECUBE(_ReflectionCube);SAMPLER(sampler_ReflectionCube);
            float4 _NormalMap_ST;
            float _NormalScale;
            float _ReflectionCubeRot;
            float4 _ReflectionVec;
            float _Roughness;
            float _SpecularIntensity;
            float _Rougness_NormalSpecular,_Rougness_NormalSpecularIntensity;
            float4 _MainTex_ST;
            float _AOMin,_AOMax,_EnableEyeAO;
            float _EnableEyeScale,_EyeScale;
            float _EnableDazEye;
            float _MinBrightness;

            Varyings LitPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS);

                output.positionCS = TransformObjectToHClip(input.positionOS);
                real sign = input.tangentOS.w * GetOddNegativeScale();
                output.tangentWS = half4(normalInput.tangentWS.xyz, sign);
                output.bitangentWS = normalInput.bitangentWS;
                output.normalWS = normalInput.normalWS;
                output.positionWS = TransformObjectToWorld(input.positionOS);
                output.uv.xy =input.uv + _MainTex_ST.zwzw;
                
                UNITY_BRANCH if(_EnableEyeScale)
                {
                    output.uv.xy =input.uv - normalize(input.uv -float2(0.5,0.5))*_EyeScale;

                    UNITY_BRANCH if(_EnableDazEye==1)
                    {
                        float2 eyeUV = frac( input.uv.xy);

                        float2 leftEyeCenter = float2(0.25,0.25);
                        float2 rightEyeCenter = float2(0.75,0.25);
                        if(eyeUV.x<0.5)
                        {
                            output.uv.xy =eyeUV - normalize(eyeUV -leftEyeCenter)*_EyeScale*0.001;
                        }
                        else
                        {
                            output.uv.xy =eyeUV - normalize(eyeUV -rightEyeCenter)*_EyeScale*0.001;
                        }
                    }
                }
                output.uv.zw =input.uv;
                return output;
            }


            float4 LitPassFragment (Varyings input) : SV_Target
            {
                #ifdef ENABLE_DISCARD_ON
                    discard;
                #endif

                //==================Shadow   ============================================== //
                float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                Light mainLight = GetMainLight(shadowCoord);
                float Shadow = mainLight.shadowAttenuation;
                Shadow = lerp(0,1,Shadow);
                
                float3 T = normalize(input.tangentWS);
                float3 MeshNomral = normalize(input.normalWS);
                float3 B = normalize(input.bitangentWS);

                float3 L = normalize(mainLight.direction);
                float3 V = normalize(_WorldSpaceCameraPos - input.positionWS);
                float3 H = normalize(V+L);

                // float sgn = input.tangentWS.w;      // should be either +1 or -1
                float3 bitangent = cross(input.normalWS.xyz, input.tangentWS.xyz);
                float3 tangentWS = cross(B,MeshNomral);//
                // half3x3 tangentToWorld = half3x3(tangentWS, bitangent.xyz, MeshNomral);
                half3x3 tangentToWorld = half3x3(tangentWS,B, MeshNomral);
                
                float2 uv = input.uv.xy;
                float EyeMask = SAMPLE_TEXTURE2D(_EyeMaskMap,sampler_EyeMaskMap,uv).r;

                //================== Normal Map  ============================================== //
                float3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv*_NormalMap_ST.xy), _NormalScale);
                
                float3 N = normalize( TransformTangentToWorld(normalTS, tangentToWorld));
                float NL = saturate(dot(N,L));
                float NV = (dot(N,V));
                float Fresnel = pow(saturate(1-dot(N,V)),5);
                // return Fresnel;

                float3 ReflectNormal = lerp(N,MeshNomral,EyeMask);
                float3 R = reflect(-V, ReflectNormal);

                //获取 CubeMap
                R = Erot(R, float3(0,1,0),_ReflectionCubeRot);
                float3 EyeReflection = SAMPLE_TEXTURECUBE(_ReflectionCube,sampler_ReflectionCube,R);

                EyeReflection = pow(EyeReflection,_ReflectionVec.x) * _ReflectionVec.y*0.1*saturate(dot(MeshNomral,L));

                float Specular =EyeMask*Specular_GGX_Skin(MeshNomral,L,V,_Roughness)*_SpecularIntensity;
                float NormalSpecular =(1-EyeMask)*Specular_GGX_Skin(N,L,V,_Rougness_NormalSpecular).r*_Rougness_NormalSpecularIntensity;
                NormalSpecular = saturate(NormalSpecular);

                float4 BaseMap = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,uv);
                // return BaseMap;
                float3 DirectDiffuse = BaseMap*saturate(dot(MeshNomral,L));
                float3 IndirectDiffuse = BaseMap*SampleSH(float4(N,1));
               
                //==================多光源   ============================================== //
                float3 additionalDiffuse = BaseMap.rgb*GetAdditionDiffuseLights(MeshNomral,input.positionWS);

                /*
                 *眼睛多光源效果不太好
                float3 additionalSpecular = GetAdditionSoecularLights(MeshNomral,V,input.positionWS,_Roughness);
                Specular += additionalSpecular;
                */
                
                float4 FinalColor =0;
                // return (IndirectSpecular*Shadow).xyzz;
                #ifdef DISAPLE_SPECULAR
                    FinalColor.rgb = DirectDiffuse*Shadow + IndirectDiffuse + additionalDiffuse;
                #else
                    FinalColor.rgb = DirectDiffuse*Shadow + IndirectDiffuse + additionalDiffuse + Specular*Shadow +NormalSpecular*Shadow + EyeReflection*Shadow;
                #endif
                
                #ifdef ONLY_SPECULAR
                    FinalColor.rgba = (Specular*Shadow +NormalSpecular*Shadow  +EyeReflection*Shadow).rrrr;
                    // FinalColor.rgba = ( 0.2 ).rrrr;
                #endif
                
                UNITY_BRANCH if (_EnableEyeAO==1)
                {
                    float aoDistance = saturate( 1-length( input.uv -float2(0.5,0.5)));
                    float ao = smoothstep(_AOMin,_AOMax,aoDistance);
                    FinalColor.rgb *= ao;
                }

                UNITY_BRANCH if(_EnableDazEye==1)
                {
                    float2 eyeUV = frac( input.uv.zw);

                    float2 leftEyeCenter = float2(0.25,0.75);
                    float2 rightEyeCenter = float2(0.75,0.75);
                    float aoDistance =1;
                    if(eyeUV.x<0.5)
                    {
                        aoDistance = saturate( 1-length( eyeUV-leftEyeCenter));
                    }
                    else
                    {
                        aoDistance = saturate( 1-length( eyeUV -rightEyeCenter));
                    }
                    float ao = smoothstep(_AOMin,_AOMax,aoDistance);
                    FinalColor.rgb *= ao;
                }
                
                // return float4(input.uv.xy,0,0);
                // FinalColor.a =1;
                FinalColor = max(_MinBrightness*BaseMap,FinalColor);
                return FinalColor;
            }
            ENDHLSL
        }
      
        //DepthOnly
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
}
