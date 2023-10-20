Shader "URP/StylizedWater"
{
    Properties
    {
        [Space(15)]
        [Header(Color)]
        [HDR]_ShallowColor("Shallow Color",Color) = (0.2,1,0.2,1)
        [HDR]_DeepColor("Deep Color",Color) = (0.2,0.2,1,1)

        _ShallowDistance("Shallow Distance",Float) = 3
        _DeepDistance("Deep Distance",Float) = 15
        _WaterAlpha("WaterAlpha",Range(0,1)) =1
        _DistortionScale("DistortionScale",Float) =1
        _DiffuseIntensity("Diffuse Intensity",Float) = 1
        _SpecularIntensity("Specular Intensity",Float) = 1
        _SpecularPow("Specular Pow",Float) = 32
        

        [Space(15)]
        [Header(Normal)]
        [NoScaleOffset]_NoiseMap("Noise",2D) = "Black"{}
        [NoScaleOffset]_NormalMap("Normal",2D) = "Black"{}
        [NoScaleOffset]_DetailNormalMap("Detail Normal",2D) = "Black"{}
        [NoScaleOffset]_NormalMapIntensity("Normal Map Intensity",Range(0,1)) = 0.2

        [Space(15)]
        [Header(Foam)]
        [Toggle(USE_FOAM)] _EnableFoam("Enable Foam",Float) =0
        _FoamRange("Foam Range",Range(0,1)) = 0.5
        _FoamWidth("Foam Width",Range(-0.5,1.5)) = 0.95
        _FoamSpeed("Foam Speed",Float) = 1.5
        _FoamIntensity("Foam Intensity",Float) = 1
        _FoamFrequency("Foam Frequency",Float) = 1
        _FoamDissolve("Foam Dissolve",Float) = 1

        [Space(15)]
        [Header(Caustic)]
        [NoScaleOffset]_CausticMap("Caustic Map",2D) ="Black"{}
        _CausticTilling("Caustic Tilling",Float) = 0.2
        _CausticIntensity("Caustic Intensity",Float) = 1
        _CausticSpeed("Caustic Speed",Float) = 2
        _CausticRange("Caustic Range",Float) = 0

        [Space(15)]
        [Header(Reflection)]
        [KeywordEnum(SSR,None)] _RefType("Reflection Type",Float) =0
        _SSRIntensity ("SSR Intensity", Range(0, 2)) = 1
        _SSRNormalDistortion("SSR Normal Distortion",Range(0,1)) = 0.15
        [HDR]_FresnelColor("_FresnelColor",Color) = (0.2,0.2,1,1)
        //_SSPRDistortion("SSPR Distortion",Float) = 1

        // [Space(15)]
        // [Header(CubeMap)]
        // [NoScaleOffset]_CubeMap("Cube Map",Cube) = "Black"{}

        [Space(15)]
        [Header(SSS)]
        [HDR]_SSSColor("SSS Color",Color) = (0.2,0.2,0.2,1)
        _SSSDistance("SSS Distance",Range(0,1)) = 0.5
        _SSSExp("SSS Exp",Range(0,1)) = 1
        _SSSIntensity("SSS Intensity",Range(0,10)) = 1

        // [Space(15)]
        // [Header(Cloud)]
        // _CloudMap ("Cloud Map", 2D) = "Black" {}
        // _CloudIntensity("Cloud Intensity",Range(0,1)) = 0.5
        // _CloudMoveSpeed("Cloud Move Speed",Float) = 0.1
        // _CloudColor("Cloud Color",Color) =(1,1,1,1)
        // _WindDirection("Wind Direction",Vector)=(1,0,0,0)
        
        [Space(15)]
        [Header(Shadow)]
        [Toggle(USE_SHADOW)] _UseShadow("Receive Shadow",Float) =0
        _ShadowIntensity("Shadowm Intensity",Range(0,1)) = 0.8
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "ShaderModel" = "4.5"
        }

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
            

            #pragma shader_feature  _REFTYPE_SSR _REFTYPE_NONE
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            float4 _ShallowColor,_DeepColor,_FresnelColor;
            TEXTURE2D(_NoiseMap);SAMPLER(sampler_NoiseMap);
            TEXTURE2D(_NormalMap);SAMPLER(sampler_NormalMap);
            TEXTURE2D(_DetailNormalMap);SAMPLER(sampler_DetailNormalMap);
            float4 _NoiseMap_ST,_DetailNormalMap_ST;
            TEXTURE2D(_CausticMap);SAMPLER(sampler_CausticMap);
            //TEXTURECUBE(_CubeMap);SAMPLER(sampler_CubeMap);
            //TEXTURE2D(_CloudMap);SAMPLER(sampler_CloudMap);
            TEXTURE2D(_CameraDepthTexture);SAMPLER(sampler_CameraDepthTexture);
            TEXTURE2D(_CameraOpaqueTexture);SAMPLER(sampler_CameraOpaqueTexture);
            TEXTURE2D(_ssprRT);SAMPLER(sampler_ssprRT);
            TEXTURE2D(_ssprBlurRT);SAMPLER(sampler_ssprBlurRT);

            float _DeepDistance,_ShallowDistance,_WaterAlpha,_DistortionScale;
            float _NormalMapIntensity;
            float4 _LightColor0;
            //float4 _MainLightColor;

            float4  _SSSColor;
            float _SSSDistance,_SSSExp,_SSSIntensity;

            //float4 _CloudMap_ST;
            //float4 _WindDirection;
            //float _WaveColorIntensity,_CloudMoveSpeed,_CloudIntensity;

            float4 _PlayerPosition;//xyz
            float _SSRIntensity,_SSRNormalDistortion;

            float _DiffuseIntensity,_SpecularIntensity,_SpecularPow;
            float _ShadowIntensity;
            float _CausticTilling,_CausticIntensity,_CausticSpeed,_CausticRange;
            float _FoamRange,_FoamWidth,_FoamSpeed,_FoamIntensity,_FoamFrequency,_FoamDissolve;

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float4 screenUV : TEXCOORD1;
                float4 shadowCoord : TEXCOORD2;
            };

            Varyings vert (Attributes input)
            {
                Varyings output = (Varyings)0;

                output.positionCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);

                output.screenUV = ComputeScreenPos(output.positionCS);//传入的是裁剪空间的坐标
                return output;
            }
//----------伪SSS
            float CheapSSS(float3 N,float3 L,float3 V,float SSSDistance,float SSSExp,float SSSIntensity)
            {
                float3 fakeN = -normalize(lerp(N,L,SSSDistance));
                float sss = SSSIntensity * pow( saturate( dot(fakeN,V)),SSSExp);
                return max(0,sss);
            }
//----------噪音函数
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
//----------SSR
            void GetScreenInfo(float4 positionCS, out float3 screenPixelNDC)
            {
                positionCS.y *= _ProjectionParams.x;//平台差异化处理
                positionCS.xyz /= positionCS.w;//手动变换到NDC空间
                positionCS.xy = positionCS*0.5+0.5;//(-1,1)->(0,1)
                screenPixelNDC.xyz = positionCS.xyz;
            }

            float GetDepth(float2 uv)//根据uv采样相机的深度
            {
                return SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, uv).r;
            }

            float4 GetSceneColor(float2 uv)//根据uv采样相机的颜色
            {
                return SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture,uv);
            }

            bool IsInClipView(float3 Ray)
            {
                if(Ray.x<0 || Ray.x>1 || Ray.y<0 || Ray.y>1 || Ray.z<0 || Ray.z>1)
                {
                    return false;
                }
                return true;
            }

            float4 WaterSSR (float3 positionWS, float3 WaterNormal)
            {
                float3 V = GetWorldSpaceViewDir(positionWS);//没有normalize，实现上的小trick
                float4 positionCS = TransformWorldToHClip(positionWS);

                float SSRlength = 15;//SSR最大反射距离
                float FarSSRlength = 50;//步进最远的距离
                float MaxLinearStep = 32;//最大步数

                float3 reflectDir = reflect(-V, WaterNormal);

                float3 endWS = positionWS + reflectDir*SSRlength;//结束点的世界坐标
                float4 ennCS = TransformWorldToHClip(endWS);

                float3 farWS = positionWS + reflectDir*FarSSRlength;//最远点的世界坐标
                float4 farCS = TransformWorldToHClip(farWS);

                float3 begin_ScreenPixelNDC, end_ScreenPixelNDC, far_ScreenPixelNDC;
                GetScreenInfo(positionCS,begin_ScreenPixelNDC);
                GetScreenInfo(ennCS,end_ScreenPixelNDC);
                GetScreenInfo(farCS,far_ScreenPixelNDC);
                //RayMarch
                float3 Step = (end_ScreenPixelNDC, begin_ScreenPixelNDC)/MaxLinearStep;//每一步的步长
                float3 Ray = begin_ScreenPixelNDC;
                float LastDepth = Ray.z;//上一次步进的深度
                bool isHit = false;
                float2 hitUV = 0;
                float4 SSRcolor = 0;
                float isFar = 0;//若远处的反射RayMarch无法Hit到则isFar=1
                float fade = pow(1-dot(normalize(V), WaterNormal), 5);//Fresnel

                //最远端在相机窗口内
                UNITY_BRANCH if(far_ScreenPixelNDC.y<1)
                {
                    float farDepth = GetDepth(far_ScreenPixelNDC.xy);
                    farDepth = LinearEyeDepth(farDepth, _ZBufferParams);//获取相机的线性深度
                    float playViewDepth = mul(unity_WorldToCamera,float4(_PlayerPosition.xyz,1));
                    //如果farDepth与玩家太近，则丢弃该反射
                    UNITY_BRANCH if(abs(playViewDepth-farDepth)>SSRlength)
                    {
                        SSRcolor = GetSceneColor(far_ScreenPixelNDC.xy)*fade;
                    }
                    else
                        SSRcolor.w = 1;
                }

                //RayMarching
                UNITY_LOOP
                for(int n=1;n<MaxLinearStep;n++)
                {
                    Ray += Step;
                    //如果测试点跑到视口外面去了那么停止for循环
                    UNITY_BRANCH if(!IsInClipView(Ray))
                        break;

                    float Depth = GetDepth(Ray.xy);

                    if(Ray.z<Depth  && Depth<LastDepth)//Ray.z<Depth<LastDepth这样写会出问题
                    {
                        isHit = true;
                        hitUV = Ray.xy;
                        break;
                    }
                    LastDepth = Ray.z;
                }
                if(isHit)
                {
                    SSRcolor = GetSceneColor(hitUV)*fade;
                }
                return SSRcolor;
            }
            half4 frag (Varyings input) : SV_Target
            {
                float4 finalColor = 0;
                float3 positionWS = input.positionWS;
                float2 screenUV = input.screenUV.xy / input.screenUV.w;//如果直接在VS中做了除法，效果会出错
                float3 V = normalize(_WorldSpaceCameraPos - input.positionWS);//视角向量
                float3 L = normalize(_MainLightPosition.xyz);//光照向量

                float4 Radiance = _LightColor0;
                float LightLum = Luminance(Radiance.xyz);

                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,sampler_CameraDepthTexture,screenUV);//实心物体有深度，半透明物体没有深度
                float3 depthWorldPosition = ComputeWorldSpacePosition(screenUV,depth,UNITY_MATRIX_I_VP);//将深度图的坐标转化到世界坐标
                float depthDistance = length(depthWorldPosition-input.positionWS);//水面到实心物体的距离
                float depthFade = saturate(depthDistance/_DeepDistance);
                finalColor = lerp(_ShallowColor,_DeepColor,depthFade);

//--------------Refraction扭曲
                float4 noise = SAMPLE_TEXTURE2D(_NoiseMap,sampler_NoiseMap,input.positionWS.xz*0.1 + float2(_Time.x,0));
                //使用噪声贴图消除重复度
                float3 normalMap = SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,input.positionWS.xz*0.05+float2(-_Time.x,0)+noise*0.05);
                normalMap.xyz = normalMap.xyz*2-1;//值域重映射(0,1)->(-1,1)
                float3 normalDetailMap = SAMPLE_TEXTURE2D(_DetailNormalMap,sampler_DetailNormalMap,input.positionWS.xz*0.1+float2(-_Time.x*0.5,0)-noise*0.05);
                normalDetailMap.xyz = normalDetailMap.xyz*2-1;//值域重映射(0,1)->(-1,1)
                float3 finalNormalMap = lerp(normalMap,normalDetailMap,0.5);
                //水面TBN固定N=float3(0,1,0);
                finalNormalMap.xyz = finalNormalMap.yxz;

                float2 distortionUV = (noise*2-1)*0.01*2*_DistortionScale;
                float4 sceneColor = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, screenUV+distortionUV);
                float distortionDistanceFade = saturate(depthDistance/_ShallowDistance);
                float4 WaterAlpha = lerp(sceneColor, finalColor, _WaterAlpha);
                finalColor = lerp(sceneColor, WaterAlpha, distortionDistanceFade);
//--------------Diffuse漫反射
                finalNormalMap = normalize(finalNormalMap);
                float3 N = lerp(float3(0,1,0), normalMap, _NormalMapIntensity);
                float NL = dot(N,L);
                float NL01 = NL*0.5+0.5;
                float diffuse = lerp(0.25,1.2,NL01);
                finalColor *= diffuse*LightLum*_DiffuseIntensity;
//--------------Diffuse漫反射
                // float3 N_Specular = lerp(float3(0,1,0),normalMap,0.1);
                float3 H = normalize(L+V);
                float NH = saturate( dot(N,H));
                // return NH;
                float specular = pow(NH,_SpecularPow)*_SpecularIntensity;
                // return specular;
                finalColor += specular*Radiance;
//--------------Foam边缘水花
                #ifdef USE_FOAM
                        // float foamDistance = 1-saturate(depthDistance/2);//此算法有bug
                        // float foamDynamic = step(1-_FoamWidth, frac(foamDistance - _Time.y*_FoamSpeed*0.1 + noise.r*0.02))*foamDistance;
                        // float foamStatic = step(1-_FoamWidth, frac(foamDistance + noise.r*0.02))*foamDistance;
                        // float foam = _FoamIntensity*max(foamDynamic,foamStatic);
                        // finalColor += foam*LightLum;
                        float foamDistance = saturate(depthDistance/_FoamRange);
                        float foamMask = 1-smoothstep(0.7,1,foamDistance+0.1);
                        float foam1 = (1-foamDistance)*_FoamFrequency-_Time.y*_FoamSpeed;
                        float foam2 = sin(foam1)+noise.r+(1-foamDistance)-_FoamDissolve;
                        float foam3 = _FoamIntensity*step((1-foamDistance)-_FoamWidth,foam2)*foamMask;
                        finalColor += foam3*LightLum;
                #endif
//--------------Caustic模拟焦散
                //用深度图的世界坐标采样 CausticMap 模拟其在水中晃动的感觉
                float4 caustic1 = SAMPLE_TEXTURE2D(_CausticMap, sampler_CausticMap, depthWorldPosition.xz*_CausticTilling + _Time.x*_CausticSpeed);
                float4 caustic2 = SAMPLE_TEXTURE2D(_CausticMap, sampler_CausticMap, -depthWorldPosition.xz*_CausticTilling + _Time.x*_CausticSpeed);
                float4 caustic = min(caustic1,caustic2);
                caustic *= saturate(_CausticRange-distortionDistanceFade);
                finalColor += caustic*_CausticIntensity*LightLum;

                // //程序化焦散 可offset uv，模拟rgb分离的效果 【性能开销大】
                // float time5 = _Time.y*0.75;
				// float2 coords = depthWorldPosition.xz*_CausticTilling + distortionUV*5;
				// float2 id5 = 0;
				// float2 uv5 = 0;
				// float caustic = voronoi5( coords, time5, id5, uv5, 0);
				// float caustic2 = voronoi5( coords+float2(0.2,0), time5, id5, uv5, 0 );
				// float caustic3 = voronoi5( coords+float2(-0.2,0), time5, id5, uv5, 0 );
                // float4 causticColor = float4(caustic,caustic2,caustic3,0);
                // causticColor =  pow(causticColor,3)*_CausticIntensity;
                // causticColor *= 1-distortionDistanceFade;
                // finalColor += causticColor*LightLum;
//--------------SSR屏幕空间反射
                //只能反射出现在屏幕中的内容
                float4 reflection = 0;
                float fresnel = pow(1-V.y,5);
                #ifdef _REFTYPE_SSR
                    float4 SSR = _SSRIntensity*WaterSSR(positionWS,lerp(float3(0,1,0),finalNormalMap/2,_SSRNormalDistortion));
                    reflection = SSR*fresnel;
                    //finalColor = lerp(finalColor, reflection*_FresnelColor, saturate(fresnel)) + fresnel*0.1;//+ cubeMap;
                    finalColor = lerp(finalColor, reflection*_FresnelColor, saturate(fresnel));
                    return finalColor;
                #endif

                #ifdef _REFTYPE_NONE
                    finalColor = lerp(finalColor, _FresnelColor, saturate(fresnel));
                #endif
//--------------SSS简易次表面散射 =======================================================================
                float4 waterSSS = CheapSSS(N,L,V,_SSSDistance,_SSSExp,_SSSIntensity)*_SSSColor;
                finalColor += waterSSS;
//--------------开启阴影
                #ifdef USE_SHADOW
                    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                    Light mainLight = GetMainLight(shadowCoord);
                    float shadow = lerp(_ShadowIntensity,1, mainLight.shadowAttenuation);
                    finalColor *= shadow;
                #endif
//
                finalColor.a =1;
                return finalColor;
            }
            ENDHLSL
        }
    }
}
