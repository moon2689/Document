Shader "Unlit/StylizedWaterSSR"
{
    Properties
    {
        [Space(15)]
        [Header(Color)]
        [HDR]_ShallowColor("Shallow Color",Color) = (0.2,1,0.2,1)
        [HDR]_DeepColor("Deep Color",Color) = (0.2,0.2,1,1)
        
        _ShallowDistance("Shallow Distance",Float) = 3
        _DeepDistance("Deep Distance",Float) = 15
        _Density("Density",Range(0,1)) =1
        _DiffuseIntensity("Diffuse Intensity",Float) = 1

        [Space(15)]
        [Header(Normal)]
        _NoiseMap("Noise",2D) = "Black"{}
        _NormalMap("Normal",2D) = "Black"{}
        _DetailNormalMap("Detail Normal",2D) = "Black"{}
        _NormalMapIntensity("Normal Map Intensity",Range(0,1)) =1

        [Space(15)]
        [Header(Caustic)]
        _CausticMap("Caustic Map",2D) ="Black"{}

        [Space(15)]
        [Header(SSR)]
        _SSRMaxSampleCount ("SSR Max Sample Count", Range(0, 64)) =64
        _SSRSampleStep ("SSR Sample Step", Range(4, 32)) = 4
        _SSRIntensity ("SSR Intensity", Range(0, 2)) = 1
        _SSRNormalDistortion("SSR Normal Distortion",Range(0,1)) = 0.15
        _SSPRDistortion("SSPR Distortion",Float) = 1
        [KeywordEnum(SSR,SSPR,None)] _RefType("Reflection Type",Float) =0

        [Space(15)]
        [Header(CubeMap)]
        _CubeMap("Cube Map",Cube) = "Black"{}

        [Space(15)]
        [Header(SSS)]
        [HDR]_SSSColor("SSS Color",Color) = (0.2,0.2,0.2,1)
        _SSSDistance("_SSSDistance",Range(0,1)) = 0.5
        _SSSExp("_SSSExp",Range(0,1)) = 1
        _SSSIntensity("_SSSIntensity",Range(0,10)) = 1
     
//        _PerPixelCompareBias("Compare Bias",Range(0,1)) =0
//        _PerPixelDepthBias("Depth Bias",Range(0,1)) =0.1

        [Space(15)]
        [Header(Cloud)]
        _CloudMap ("Cloud Map", 2D) = "Black" {}
        _CloudIntensity("Cloud Intensity",Range(0,1)) = 0.5
        _CloudMoveSpeed("Cloud Move Speed",Float) = 0.1
        _CloudColor("Cloud Color",Color) =(1,1,1,1)
        _WindDirection("Wind Direction",Vector)=(1,0,0,0)
        
        [Space(15)]
        [Header(Shadow)]
        [Toggle(USE_SHADOW)] _UseShadow("Receive Shadow",Float) =0
        _ShadowIntensity("Shadowm Intensity",Range(0,1)) = 0.8

        [Space(15)]
        [Header(Foam)]
        [Toggle(USE_FOAM)] _EnableFoam("Enable Foam",Float) =0
        _FoamWidth("Foam Width",Range(0,1)) = 0.95
        _FoamSpeed("Foam Speed",Float) = 1
    }
    SubShader
    {
        Tags { "Queue" = "Transparent"  "RenderPipeline" = "UniversalPipeline" "ShaderModel" = "4.5" }

        Pass
        {
            Name "StylizedWaterSSR"

            HLSLPROGRAM
            #pragma target 4.5

            #pragma vertex vert
            #pragma fragment frag

            // Universal Render Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

            #pragma shader_feature _ USE_SHADOW
            #pragma shader_feature _ USE_FOAM
            

            #pragma shader_feature  _REFTYPE_SSR _REFTYPE_SSPR _REFTYPE_NONE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            
            // #include "WaterSSR.cginc"

            // #define USE_SHADOW

            float4 _ShallowColor,_DeepColor;

            TEXTURE2D(_NoiseMap);SAMPLER(sampler_NoiseMap);
            TEXTURE2D(_NormalMap);SAMPLER(sampler_NormalMap);
            TEXTURE2D(_DetailNormalMap);SAMPLER(sampler_DetailNormalMap);
            float4 _NoiseMap_ST,_DetailNormalMap_ST;
            TEXTURE2D(_CausticMap);SAMPLER(sampler_CausticMap);
            TEXTURECUBE(_CubeMap);SAMPLER(sampler_CubeMap);
            TEXTURE2D(_CloudMap);SAMPLER(sampler_CloudMap);
            TEXTURE2D(_CameraOpaqueTexture);SAMPLER(sampler_CameraOpaqueTexture);
            TEXTURE2D(_CameraDepthTexture);SAMPLER(sampler_CameraDepthTexture);
            
            TEXTURE2D(ssprRT);SAMPLER(sampler_ssprRT);
            TEXTURE2D(ssprBlurRT);SAMPLER(sampler_ssprBlurRT);

            // Texture2D _NoiseMap; SamplerState sampler_NoiseMap;
            // Texture2D _NormalMap; SamplerState sampler_NormalMap;
            // Texture2D _DetailNormalMap;SamplerState sampler_DetailNormalMap;float4 _DetailNormalMap_ST;

            float _DeepDistance,_ShallowDistance,_Density;

            float _NormalMapIntensity;
            float4 _LightColor0;

            float4  _SSSColor;
            float _SSSDistance,_SSSExp,_SSSIntensity;

            float4 _CloudMap_ST;
            float4 _WindDirection;
            float _WaveColorIntensity,_CloudMoveSpeed,_CloudIntensity;

            float4 _PlayerPosition;//xyz
            float _SSRIntensity,_SSRNormalDistortion,_SSPRDistortion;

            float _DiffuseIntensity;
            float _ShadowIntensity;

            float _FoamWidth,_FoamSpeed;
            
            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float4 screenUV   : TEXCOORD1;
                float4 shadowCoord: TEXCOORD2;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                output.positionCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                output.screenUV  =  ComputeScreenPos(output.positionCS);
                return output;
            }

            float CheapSSS(float3 N,float3 L,float3 V,float SSSDistance,float SSSExp,float SSSIntensity)
            {
                float3 fakeN = -normalize(lerp(N,L,SSSDistance));
                float sss = SSSIntensity * pow( saturate( dot(fakeN,V)),SSSExp);
                return max(0,sss);
            }

            float2 voronoihash5( float2 p )
            {
                
                p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
                return frac( sin( p ) *43758.5453);
            }
    
            float voronoi5( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
            {
                float2 n = floor( v );
                float2 f = frac( v );
                float F1 = 8.0;
                float F2 = 8.0; float2 mg = 0;
                for ( int j = -1; j <= 1; j++ )
                {
                    for ( int i = -1; i <= 1; i++ )
                    {
                        float2 g = float2( i, j );
                        float2 o = voronoihash5( n + g );
                        o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
                        float d = 0.5 * dot( r, r );
                        if( d<F1 ) {
                            F2 = F1;
                            F1 = d; mg = g; mr = r; id = o;
                        } else if( d<F2 ) {
                            F2 = d;
                        }
                    }
                }
                return (F2 + F1) * 0.5;
            }

            // x = width
            // y = height
            // z = 1 + 1.0/width
            // w = 1 + 1.0/height
            //float4 _ScreenParams;

             // x = 1 or -1 (-1 if projection is flipped)
            // y = near plane
            // z = far plane
            // w = 1/far plane
            // float4 _ProjectionParams;

            //screenPixelNdcZ xy: screenPixel z:ndcZ
            void GetScreenInfo(float4 positionCS,out float3 screenPixelNdcZ)
            {
                positionCS.y *= _ProjectionParams.x;
                positionCS.xyz /= positionCS.w;//ndc
                positionCS.xy = positionCS*0.5+0.5;//xy [-1,1] z:[1,0]
                // return float4( positionCS.xy,0,0);
                screenPixelNdcZ.xyz = positionCS.xyz;// NDC空间坐标
            }

            float GetDepth(float2 uv)
            {
                return SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, uv).r;
            }

            float4 GetSceneColor(float2 uv)
            {
                return SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture,uv);
            }

            bool IsInClipView(float3 Ray)
            {
                if(Ray.z<0 || Ray.z>1 || Ray.x<0 || Ray.x>1 || Ray.y<0 || Ray.y>1)
                {
                    return false;
                }
                return true;
            }

            float4 WaterSSR(float3 positionWS,float3 waterNormal=float3(0,1,0))
            {
                float3 V = ( GetWorldSpaceViewDir(positionWS));
                float4 positionCS = TransformWorldToHClip(positionWS);
                
                float SSRLength = 15;
                float FarSSRLength = 50;
                float MaxLingearStep = 32;
                
                float3 reflectDir = reflect(-V,waterNormal);
                float3 endWS = positionWS + reflectDir*SSRLength;
                float4 endPositionCS = TransformWorldToHClip(endWS);
                
                float3 farWS = positionWS + reflectDir*FarSSRLength;
                float4 farPositionCS = TransformWorldToHClip(farWS);

                float3 begin_ScreenPixelNdcZ , end_ScreenPixelNdcZ,far_ScreenPixelNdcZ;
                
                GetScreenInfo(positionCS,begin_ScreenPixelNdcZ);
                GetScreenInfo(endPositionCS,end_ScreenPixelNdcZ);
                GetScreenInfo(farPositionCS,far_ScreenPixelNdcZ);
                // return  begin_ScreenPixelNdcZ.z;
                // return end_ScreenPixelNdcZ.z;

                float3 Step = (end_ScreenPixelNdcZ-begin_ScreenPixelNdcZ)/MaxLingearStep;
                float3 Ray = begin_ScreenPixelNdcZ;
                bool isHit = false;
                float2 hitUV = (float2)0;
                
                float LastDepth =Ray.z;

                float4 SSRColor = 0;
                //远处的反射 RayMarch 无法Hit到
                // float isFar = 1;
                float isFar=0;

                float fade = pow(1-dot(normalize(V),waterNormal),5);//fresnel
                
                
                // 最远端在相机视口内
                UNITY_BRANCH if((far_ScreenPixelNdcZ).y<1)
                {
                    float farDepth =  GetDepth(far_ScreenPixelNdcZ.xy);

                    farDepth = LinearEyeDepth(farDepth,_ZBufferParams);
                    
                    float playViewDepth = mul(unity_WorldToCamera,float4(_PlayerPosition.xyz,1));

                    //如果farDepth与玩家太近，那么丢弃该反射
                   UNITY_BRANCH if(abs(playViewDepth-farDepth)>SSRLength)
                    {
                        // SSRColor =  GetSceneColor(far_ScreenPixelNdcZ.xy)*fade*float4(1,0,0,0);
                        SSRColor =  GetSceneColor(far_ScreenPixelNdcZ.xy)*fade;
                    }
                    else
                    {
                        SSRColor.w =1;
                    }
                }
                // return  SSRColor;
                
                
                UNITY_LOOP
                for (int n=1;n<MaxLingearStep;n++)
                {
                    Ray += Step;
                    //如果测试点跑到 视口外面去了，那么停止for循环
                    UNITY_BRANCH if(Ray.z<0 || Ray.z>1 || Ray.x<0 || Ray.x>1 || Ray.y<0 || Ray.y>1)
                    {
                        break;
                    }

                    float Depth = GetDepth(Ray.xy);

                    //  上一次深度<Depth<这一次深度
                    // if(Depth + _PerPixelCompareBias >Ray.z && Ray.z <Depth +_PerPixelDepthBias )
                    if(Ray.z<Depth  && Depth<LastDepth)
                    {
                        isHit = true;
                        hitUV = Ray.xy;
                        break;
                    }
                    LastDepth =Ray.z;
                }

                if(isHit)
                {
                    SSRColor =  GetSceneColor(hitUV)*fade;
                }
                return  SSRColor;
            }

            half4 frag(Varyings input) : SV_Target
            {
                // return input.testUV.w/ -input.testUV.z;
                float4 finalColor = 0;
                float3 positionWS = input.positionWS;
                float2 screenUV = input.screenUV.xy / input.screenUV.w;//直接在VS中做了除法，效果会出错
                float3 V = normalize( _WorldSpaceCameraPos - positionWS);
                // float3 V = ( GetWorldSpaceViewDir(positionWS));
                float3 L = normalize(_MainLightPosition.xyz);
                
                
//===================== Light Setting =======================================================================
                float4 Radiance = _LightColor0;
                float LightLum = Luminance(Radiance.xyz);
                
 //===================== Depth Fade 根据深度颜色变换 =======================================================================
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, screenUV);
                float3 depthWorldPosition = ComputeWorldSpacePosition(screenUV, depth, UNITY_MATRIX_I_VP);

                float depthDistance = length(depthWorldPosition - input.positionWS);
                float depthFade = saturate( depthDistance/_DeepDistance);
                finalColor = lerp(_ShallowColor,_DeepColor,depthFade);
                
//===================== Refraction  扭曲 =======================================================================
                float4 noise = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, input.positionWS.xz*0.1 + float2(-_Time.x*0.5,0) );
               
                //用噪音扰动NormalMap消除Tilling感
                float3 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.positionWS.xz *0.025 +float2(_Time.x*0.5,0) +noise*0.02 );
                normalMap.xyz = normalMap.xyz*2-1;

                float3 normalDetailMap = SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap, input.positionWS.xz +float2(-_Time.x*0.3,0)-noise*0.02);
                normalDetailMap.xyz = normalDetailMap.xyz*2-1;
                
                normalMap = lerp(normalMap,normalDetailMap,0.5);

                //水面TBN固定 N=float3(0,1,0)
                //trick 简化计算，将NormalMap 转 到世界空间 
                normalMap.xyz = normalMap.yxz;

                float2 distortionUV = (noise*2-1)*0.01*2;
                float4 sceneColor = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, screenUV +distortionUV );
                float distortionDistanceFade = saturate( depthDistance/_ShallowDistance);
                finalColor = lerp(sceneColor,lerp(sceneColor,finalColor,_Density),distortionDistanceFade);
                
 //===================== Diffuse 漫反射 =======================================================================
                normalMap = normalize(normalMap);
                float3 N = normalize( lerp(float3(0,1,0),normalMap,_NormalMapIntensity) );
                float NL = dot(N,L);
                float NL01 = NL*0.5+0.5;
                float diffuse = lerp(0.25,1.2,NL01);
                finalColor *= diffuse*LightLum*_DiffuseIntensity;

 //===================== Specular 高光 =======================================================================
                // float3 N_Specular = lerp(float3(0,1,0),normalMap,0.1);
                float3 H = normalize(L+V);
                float NH = saturate( dot(N,H));
                // return NH;
                float specular = pow(NH,32);
                // return specular;
                finalColor += specular*Radiance.xyzz;
                
 //===================== Foam 边缘水花=======================================================================
                #ifdef USE_FOAM
                    // return _NoiseMap.Sample(sampler_NoiseMap,  input.positionWS.xz*0.1 + float2(_Time.x*2,0));
                    float foamDistance = 1- saturate(depthDistance/2);
                    float foamDynamic = 0.5* step( _FoamWidth,frac(foamDistance + _Time.y*0.1*_FoamSpeed + noise.r*0.0225)) * foamDistance*foamDistance;
                    float foamStatic =  0.5*step( _FoamWidth,frac(foamDistance  + noise.r*0.02525)) * foamDistance*foamDistance;
                    float foam = max(foamDynamic,foamStatic);
                    finalColor += foam*LightLum;
                #endif

//===================== Caustic 模拟焦散 =======================================================================
                //用深度图的世界坐标采样 CausticMap 模拟其在水中晃动的感觉
                //贴图焦散
                float4 caustic = SAMPLE_TEXTURE2D(_CausticMap, sampler_CausticMap, depthWorldPosition.xz*0.2+distortionUV*5);
                caustic *= 1-distortionDistanceFade;
                finalColor += caustic*0.3*LightLum;
                
                /*
                //程序化焦散 可offset uv，模拟rgb分离的效果 【性能开销大】
                float time5 = _Time.y*0.75;
				float2 coords = depthWorldPosition.xz * 0.75 +distortionUV*10;
				float2 id5 = 0;
				float2 uv5 = 0;
				float caustic = voronoi5( coords, time5, id5, uv5, 0);
				float caustic2 = voronoi5( coords+float2(0.2,0), time5, id5, uv5, 0 );
				float caustic3 = voronoi5( coords+float2(-0.2,0), time5, id5, uv5, 0 );
                float4 causticColor = float4(caustic,caustic2,caustic3,0);
                causticColor =  pow(causticColor,3)*3;
                causticColor *= 1-distortionDistanceFade;
                finalColor += causticColor*LightLum;
                */
   
//===================== Cloud 云=======================================================================
                float2 cloudMapUV = positionWS.xz*_CloudMap_ST.xy*0.01 + _WindDirection.xy* _CloudMoveSpeed*_Time.y;
                float cloudMap = SAMPLE_TEXTURE2D(_CloudMap,sampler_CloudMap,cloudMapUV).r;
                float cloud = cloudMap * _CloudIntensity;
                finalColor +=cloud;
                
            //       float4 _CloudMap_ST;
            // float4 _WindDirection;
            // float _WaveColorIntensity,_CloudMoveSpeed;


                 // 
 //===================== CubeMap 反射 =======================================================================
                V = normalize(V);
                float3 R = reflect(-V,normalize( lerp(float3(0,1,0),normalMap,0.15) ));
                float4 fresnel = ( pow(  1-V.y,5));
                float4 cubeMap = SAMPLE_TEXTURECUBE(_CubeMap,sampler_CubeMap,R);
                // cubeMap = cubeMap *(1-fresnel)*0.2;
                
                // return cubeMap;
                // finalColor += cubeMap*lerp(0.1,0.5,NL01)*LightLum;
                // reflection += cubeMap*0.5;
// 
//===================== SSR  屏幕空间反射=======================================================================
                float4 reflection =0;
                #ifdef _REFTYPE_SSR 
                    float4 ssr =_SSRIntensity* WaterSSR(positionWS, lerp(float3(0,1,0),normalMap,_SSRNormalDistortion));
                    reflection = ssr*fresnel;
                #endif
//===================== SSPR  屏幕空间平面反射=======================================================================

                #ifdef _REFTYPE_SSPR
                    // float4 sspr = SAMPLE_TEXTURE2D(ssprBlurRT, sampler_ssprBlurRT, screenUV + (normalMap.xz)*0.05*_SSPRDistortion);
                    float4 sspr = _SSRIntensity* SAMPLE_TEXTURE2D(ssprBlurRT, sampler_ssprBlurRT, screenUV + (normalMap.xz)*_SSPRDistortion );
                    // float4 sspr = SAMPLE_TEXTURE2D(ssprRT, sampler_ssprRT, screenUV + (normalMap.xz)*0.05*_SSPRDistortion);
                    reflection = sspr*fresnel;
                // return sspr;
                // ssr = sspr*fresnel;
                #endif

                #ifdef _REFTYPE_NONE
                    reflection = 0;
                #endif

                // sspr = lerp(cubeMap,sspr,sspr.a);
                // return sspr;
                // if(sspr.a==0.5)
                // {
                //     return float4(1,0,0,1);
                // }
                  
                // sspr = lerp(finalColor,sspr,sspr.a);
                  // return sspr;
                // ssr = sspr*( pow(  1-V.y,2));
                // sspr.a =1;
                 // return sspr;

                //模拟菲尼尔 远处反射 近处水本身的颜色
                // finalColor = lerp( finalColor,reflection, fresnel) + ssr;
                // finalColor += reflection + ssr;
                finalColor = lerp( finalColor,reflection, saturate( fresnel)) + fresnel*0.1 ;//+ cubeMap;
 //===================== SSS 简易次表面散射 =======================================================================
                float4 waterSSS = CheapSSS(N,L,V,_SSSDistance,_SSSExp,_SSSIntensity)*_SSSColor;
                
                finalColor += waterSSS;

                #ifdef USE_SHADOW
                    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                    Light mainLight = GetMainLight(shadowCoord);
                    float shadow = lerp(_ShadowIntensity,1, mainLight.shadowAttenuation);
                    finalColor *= shadow;
                #endif

                finalColor.a =1;
                return finalColor;
                // return frac( abs( (depthWorldPosition) )).xyzz;
                // return ssr;
              
            }
            ENDHLSL

        }
    }
}
