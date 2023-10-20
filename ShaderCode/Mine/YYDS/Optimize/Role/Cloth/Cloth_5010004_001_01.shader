Shader "TA/Optimize/Role/Cloth/5010004_001_01"
{
	Properties
	{
		_Diffuse_Front("Diffuse_Front", 2D) = "white" {}
		_Diffuse_FrontMultiple("Diffuse_FrontMultiple", Float) = 1
		_Diffuse_BackMultiple("Diffuse_BackMultiple", Float) = 1
		_Diffuse_Back("Diffuse_Back", 2D) = "white" {}
		_SMAO_Front("SMAO_Front", 2D) = "white" {}
		_SMAO_Back("SMAO_Back", 2D) = "white" {}
		_Normal_Front("Normal_Front", 2D) = "bump" {}
		_Normal_Back("Normal_Back", 2D) = "bump" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0.2
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		_AO("AO", Range( 0 , 1)) = 0
		_FresnelBiss("FresnelBiss", Range( -0.5 , 0.5)) = 0
		_FresnelScale("FresnelScale", Float) = 0.5
		_FresnelPower("FresnelPower", Float) = 2
		_FresnelColor("FresnelColor", Color) = (0.259434,1,0.9389895,0)
		_Brightness("Brightness", Float) = 1
		_skybox_001("skybox_001", CUBE) = "white" {}
		_MetallicReflection("MetallicReflection", Float) = 1
		_MetallicReflectionColor("MetallicReflectionColor", Color) = (1,1,1,0)
		_Reflection("Reflection", Float) = 1
		_ReflectionColor("ReflectionColor", Color) = (1,1,1,0)
		_StarrySky_1("StarrySky_1", 2D) = "white" {}
		_StarrySkyRotationSpeed_1("StarrySkyRotationSpeed_1", Range( 0 , 2)) = 0.5
		_StarrySkyRotationSpeed_2("StarrySkyRotationSpeed_2", Range( 0 , 2)) = 0
		_StarrySky2repeatUV("StarrySky2repeatUV", Vector) = (2,1,0,0)
		[Toggle]_Flowswitch("Flow switch", Float) = 0
		_SequinsNoise("SequinsNoise", 2D) = "white" {}
		_Sequins_F1Strength("Sequins_F1Strength", Float) = 1
		[HDR]_Sequins_F1Color("Sequins_F1Color", Color) = (0.7454045,0.5583406,0.2788943,1)
		_Sequins_F1Threshold("Sequins_F1Threshold", Range( 0 , 1)) = 0.5
		_Sequins_F1Range("Sequins_F1Range", Range( 0 , 1)) = 0.2
		_Sequins_F1SpakleSpeed("Sequins_F1Spakle Speed", Range( 0 , 0.01)) = 0.00136
		_Sequins_F1ScreenContribution("Sequins_F1ScreenContribution", Range( 0 , 3)) = 0.029
		_Sequins_F1Frequency("Sequins_F1Frequency", Range( 0 , 10)) = 1.3
		_SequinsAttenuation_1F1("SequinsAttenuation_1+F1", Range( 0 , 6)) = 1.452571
		_SequinsAttenuation_DarkSideF1("SequinsAttenuation_DarkSideF1", Range( -1 , 6)) = 4.30903
		_SequinsAttenuation_MinNewF1("SequinsAttenuation_MinNewF1", Range( 0 , 2)) = 1.452571
		_SequinsAttenuation_MaxNewF1("SequinsAttenuation_MaxNewF1", Range( 0 , 2)) = 1
		_Sequins_F2Strength("Sequins_F2Strength", Float) = 1
		[HDR]_Sequins_F2Color("Sequins_F2Color", Color) = (0.7454045,0.5583406,0.2788943,1)
		_Sequins_F2Threshold("Sequins_F2Threshold", Range( 0 , 1)) = 0.5
		_Sequins_F2Range("Sequins_F2Range", Range( 0 , 1)) = 0.2
		_Sequins_F2SpakleSpeed("Sequins_F2Spakle Speed", Range( 0 , 0.01)) = 0.00136
		_Sequins_F2ScreenContribution("Sequins_F2ScreenContribution", Range( 0 , 3)) = 0.029
		_Sequins_F2Frequency("Sequins_F2Frequency", Range( 0 , 10)) = 1.3
		_SequinsAttenuation_1F2("SequinsAttenuation_1+F2", Range( 0 , 6)) = 1.452571
		_SequinsAttenuation_DarkSideF2("SequinsAttenuation_DarkSideF2", Range( -1 , 6)) = 4.30903
		_SequinsAttenuation_MinNewF2("SequinsAttenuation_MinNewF2", Range( 0 , 2)) = 1.452571
		_SequinsAttenuation_MaxNewF2("SequinsAttenuation_MaxNewF2", Range( 0 , 2)) = 1
		_Sequins_B("Sequins_B", Float) = 2
		[HDR]_SequinsColor_B("SequinsColor_B", Color) = (1,0.7993915,0.3676471,0)
		_Threshold_B("Threshold_B", Range( 0 , 1)) = 0.5
		_Range_B("Range_B", Range( 0 , 1)) = 0.2
		_SpakleSpeed_B("Spakle Speed_B", Range( 0 , 0.01)) = 0.00136
		_ScreenContribution_B("Screen Contribution_B", Range( 0 , 1)) = 0.029
		[ASEEnd]_Frequency_B("Frequency_B", Range( 0 , 10)) = 1.3
	}


	SubShader
	{
		LOD 500
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Cull Off
			

			HLSLPROGRAM
			#pragma target 3.0
			#pragma multi_compile _ LOD_FADE_CROSSFADE

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

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "../../Library/UnityBRDF_Common.hlsl"

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				float4 screenPos : TEXCOORD6;
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Diffuse_Front_ST;
			float4 _SMAO_Back_ST;
			float4 _SequinsNoise_ST;
			float4 _SequinsColor_B;
			float4 _FresnelColor;
			float4 _Sequins_F1Color;
			float4 _SMAO_Front_ST;
			float4 _Sequins_F2Color;
			float4 _MetallicReflectionColor;
			float4 _ReflectionColor;
			float4 _Normal_Back_ST;
			float4 _Normal_Front_ST;
			float4 _StarrySky_1_ST;
			float4 _Diffuse_Back_ST;
			float2 _StarrySky2repeatUV;
			float _FresnelBiss;
			float _SequinsAttenuation_MaxNewF2;
			float _MetallicReflection;
			float _FresnelScale;
			float _FresnelPower;
			float _AO;
			float _Brightness;
			float _SequinsAttenuation_MinNewF2;
			float _Threshold_B;
			float _Range_B;
			float _ScreenContribution_B;
			float _Frequency_B;
			float _SpakleSpeed_B;
			float _Sequins_B;
			float _Reflection;
			float _SequinsAttenuation_DarkSideF2;
			float _Sequins_F2ScreenContribution;
			float _Sequins_F2Strength;
			float _Diffuse_BackMultiple;
			float _StarrySkyRotationSpeed_1;
			float _StarrySkyRotationSpeed_2;
			float _Flowswitch;
			float _Diffuse_FrontMultiple;
			float _Sequins_F1Threshold;
			float _Sequins_F1Range;
			float _Sequins_F1ScreenContribution;
			float _Sequins_F1Frequency;
			float _SequinsAttenuation_1F2;
			float _Sequins_F1SpakleSpeed;
			float _SequinsAttenuation_1F1;
			float _SequinsAttenuation_DarkSideF1;
			float _SequinsAttenuation_MinNewF1;
			float _SequinsAttenuation_MaxNewF1;
			float _Sequins_F2Threshold;
			float _Sequins_F2Range;
			float _Metallic;
			float _Sequins_F2Frequency;
			float _Sequins_F2SpakleSpeed;
			float _Sequins_F1Strength;
			float _Smoothness;
			CBUFFER_END
			sampler2D _SMAO_Front;
			sampler2D _SequinsNoise;
			sampler2D _Normal_Front;
			sampler2D _Normal_Back;
			sampler2D _Diffuse_Front;
			sampler2D _Diffuse_Back;
			sampler2D _SMAO_Back;
			samplerCUBE _skybox_001;
			sampler2D _StarrySky_1;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord8.xyz = v.texcoord.xyz;
				o.ase_texcoord9.xy = v.texcoord1.xy;
				o.ase_texcoord8.w = 0;
				o.ase_texcoord9.zw = 0;
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );
				half fogFactor = 0;
				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				
				o.clipPos = positionCS;
				o.screenPos = ComputeScreenPos(positionCS);
				return o;
			}
			
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}

			half4 frag ( VertexOutput IN , bool ase_vface : SV_IsFrontFace ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 WorldNormal = normalize( IN.tSpace0.xyz );
				float3 WorldTangent = IN.tSpace1.xyz;
				float3 WorldBiTangent = IN.tSpace2.xyz;
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				WorldViewDirection = SafeNormalize( WorldViewDirection );
				float4 ScreenPos = IN.screenPos;

				float2 uv_SMAO_Front = IN.ase_texcoord8.xyz.xy * _SMAO_Front_ST.xy + _SMAO_Front_ST.zw;
				float4 tex2DNode13 = tex2D( _SMAO_Front, uv_SMAO_Front );
				float Sequins_Mask248 = tex2DNode13.a;
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 temp_output_325_0 = (ase_screenPosNorm).xy;
				float2 uv_SequinsNoise = IN.ase_texcoord8.xyz.xy * _SequinsNoise_ST.xy + _SequinsNoise_ST.zw;
				float2 temp_output_276_0 = ( uv_SequinsNoise * _Sequins_F1Frequency );
				float mulTime271 = _TimeParameters.x * _Sequins_F1SpakleSpeed;
				float smoothstepResult283 = smoothstep( _Sequins_F1Threshold , ( _Sequins_F1Threshold + _Sequins_F1Range ) , ( tex2D( _SequinsNoise, ( ( temp_output_325_0 * _Sequins_F1ScreenContribution ) + temp_output_276_0 + mulTime271 ) ).g * tex2D( _SequinsNoise, ( ( temp_output_276_0 * 1.1 ) + -mulTime271 ) ).g ));
				float2 uv_Normal_Front = IN.ase_texcoord8.xyz.xy * _Normal_Front_ST.xy + _Normal_Front_ST.zw;
				float2 uv_Normal_Back = IN.ase_texcoord8.xyz.xy * _Normal_Back_ST.xy + _Normal_Back_ST.zw;
				float3 switchResult163 = (((ase_vface>0)?(UnpackNormalScale( tex2D( _Normal_Front, uv_Normal_Front ), 1.0f )):(UnpackNormalScale( tex2D( _Normal_Back, uv_Normal_Back ), 1.0f ))));
				float3 Normal116 = switchResult163;
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal330 = Normal116;
				float3 worldNormal330 = normalize( float3(dot(tanToWorld0,tanNormal330), dot(tanToWorld1,tanNormal330), dot(tanToWorld2,tanNormal330)) );
				float dotResult328 = dot( worldNormal330 , _MainLightPosition.xyz );
				float Light349 = dotResult328;
				float2 temp_output_299_0 = ( uv_SequinsNoise * _Sequins_F2Frequency );
				float mulTime294 = _TimeParameters.x * _Sequins_F2SpakleSpeed;
				float smoothstepResult306 = smoothstep( _Sequins_F2Threshold , ( _Sequins_F2Threshold + _Sequins_F2Range ) , ( tex2D( _SequinsNoise, ( ( temp_output_325_0 * _Sequins_F2ScreenContribution ) + temp_output_299_0 + mulTime294 ) ).g * tex2D( _SequinsNoise, ( ( temp_output_299_0 * 1.1 ) + -mulTime294 ) ).g ));
				float4 Sequins_F337 = ( ( _Sequins_F1Color * smoothstepResult283 * _Sequins_F1Strength * saturate( (_SequinsAttenuation_MinNewF1 + ((Light349*( 1.0 + _SequinsAttenuation_1F1 ) + _SequinsAttenuation_DarkSideF1) - 0.0) * (_SequinsAttenuation_MaxNewF1 - _SequinsAttenuation_MinNewF1) / (1.0 - 0.0)) ) ) + ( _Sequins_F2Color * smoothstepResult306 * _Sequins_F2Strength * saturate( (_SequinsAttenuation_MinNewF2 + ((Light349*( 1.0 + _SequinsAttenuation_1F2 ) + _SequinsAttenuation_DarkSideF2) - 0.0) * (_SequinsAttenuation_MaxNewF2 - _SequinsAttenuation_MinNewF2) / (1.0 - 0.0)) ) ) );
				float fresnelNdotV46 = dot( WorldNormal, WorldViewDirection );
				float fresnelNode46 = ( _FresnelBiss + _FresnelScale * pow( max( 1.0 - fresnelNdotV46 , 0.0001 ), _FresnelPower ) );
				float4 switchResult169 = (((ase_vface>0)?(( fresnelNode46 * _FresnelColor )):(float4( 0,0,0,0 ))));
				float2 uv_Diffuse_Front = IN.ase_texcoord8.xyz.xy * _Diffuse_Front_ST.xy + _Diffuse_Front_ST.zw;
				float4 tex2DNode6 = tex2D( _Diffuse_Front, uv_Diffuse_Front );
				float2 uv_Diffuse_Back = IN.ase_texcoord8.xyz.xy * _Diffuse_Back_ST.xy + _Diffuse_Back_ST.zw;
				float4 switchResult158 = (((ase_vface>0)?(tex2DNode6):(( tex2D( _Diffuse_Back, uv_Diffuse_Back ) * _Diffuse_BackMultiple ))));
				float4 cloth_D_F103 = switchResult158;
				float2 uv_SMAO_Back = IN.ase_texcoord8.xyz.xy * _SMAO_Back_ST.xy + _SMAO_Back_ST.zw;
				float4 tex2DNode162 = tex2D( _SMAO_Back, uv_SMAO_Back );
				float switchResult160 = (((ase_vface>0)?(tex2DNode13.g):(tex2DNode162.g)));
				float Metallic93 = switchResult160;
				float3 worldRefl84 = reflect( -WorldViewDirection, float3( dot( tanToWorld0, Normal116 ), dot( tanToWorld1, Normal116 ), dot( tanToWorld2, Normal116 ) ) );
				float4 texCUBENode78 = texCUBE( _skybox_001, worldRefl84 );
				float switchResult161 = (((ase_vface>0)?(tex2DNode13.r):(tex2DNode162.r)));
				float Smoothness92 = switchResult161;
				float switchResult159 = (((ase_vface>0)?(tex2DNode13.b):(tex2DNode162.b)));
				float AO94 = switchResult159;
				float4 lerpResult119 = lerp( cloth_D_F103 , ( cloth_D_F103 * AO94 ) , _AO);
				float4 temp_output_53_0 = ( switchResult169 + ( cloth_D_F103 * ( _MetallicReflection * Metallic93 * _MetallicReflectionColor * texCUBENode78 ) ) + ( ( texCUBENode78 * _ReflectionColor ) * ( 1.0 - Smoothness92 ) * _Reflection ) + ( _Brightness * lerpResult119 ) );
				float2 temp_output_229_0 = ( uv_SequinsNoise * _Frequency_B );
				float mulTime210 = _TimeParameters.x * _SpakleSpeed_B;
				float smoothstepResult207 = smoothstep( _Threshold_B , ( _Threshold_B + _Range_B ) , ( tex2D( _SequinsNoise, ( ( (ase_screenPosNorm).xy * _ScreenContribution_B ) + temp_output_229_0 + mulTime210 ) ).g * tex2D( _SequinsNoise, ( ( temp_output_229_0 * 1.1 ) + -mulTime210 ) ).g ));
				float4 Sequins_B223 = ( _SequinsColor_B * smoothstepResult207 * _Sequins_B );
				float4 switchResult240 = (((ase_vface>0)?(( ( Sequins_Mask248 * Sequins_F337 ) + temp_output_53_0 )):(( temp_output_53_0 + ( Sequins_Mask248 * Sequins_B223 ) ))));
				float2 uv2_StarrySky_1 = IN.ase_texcoord9.xy * _StarrySky_1_ST.xy + _StarrySky_1_ST.zw;
				float2 panner396 = ( 1.0 * _Time.y * float2( -0.02,0 ) + uv2_StarrySky_1);
				float StarrySkyRotationSpeed_1545 = _StarrySkyRotationSpeed_1;
				float2 Offset183 = ( ( 0.0 - 1 ) * WorldViewDirection.xy * StarrySkyRotationSpeed_1545 ) + panner396;
				float2 StarrySky2repeatUV549 = _StarrySky2repeatUV;
				float2 texCoord192 = IN.ase_texcoord9.xy * StarrySky2repeatUV549 + float2( 0,0 );
				float2 panner395 = ( 1.0 * _Time.y * float2( 0.03,0 ) + texCoord192);
				float StarrySkyRotationSpeed_2547 = _StarrySkyRotationSpeed_2;
				float2 Offset189 = ( ( 0.0 - 1 ) * WorldViewDirection.xy * StarrySkyRotationSpeed_2547 ) + panner395;
				float2 texCoord247 = IN.ase_texcoord9.xy * float2( 1,1 ) + float2( 0,0 );
				float Flowswitch551 = _Flowswitch;
				float4 lerpResult187 = lerp( switchResult240 , ( ( tex2D( _StarrySky_1, Offset183 ) + tex2D( _StarrySky_1, Offset189 ) ) / 2.0 ) , ( tex2D( _StarrySky_1, texCoord247 ).a * Flowswitch551 ));
				float Diffuse_FrontMultiple417 = _Diffuse_FrontMultiple;
				
				float cloth_A105 = tex2DNode6.a;
				
				float3 Albedo = ( lerpResult187 * Diffuse_FrontMultiple417 ).rgb;
				float3 Normal = Normal116;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = ( Metallic93 * _Metallic );
				float Smoothness = ( ( 1.0 - Smoothness92 ) * _Smoothness );
				float Occlusion = 1;
				float Alpha = cloth_A105;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				clip(Alpha - 0.5);

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
				inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				float3 SH = IN.lightmapUVOrVertexSH.xyz;
				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

				SurfaceData surfaceData;
				surfaceData.albedo              = Albedo;
				surfaceData.metallic            = saturate(Metallic);
				surfaceData.specular            = Specular;
				surfaceData.smoothness          = saturate(Smoothness),
				surfaceData.occlusion           = Occlusion,
				surfaceData.emission            = Emission,
				surfaceData.alpha               = saturate(Alpha);
				surfaceData.normalTS            = Normal;
				surfaceData.clearCoatMask       = 0;
				surfaceData.clearCoatSmoothness = 1;

				half4 color = UniversalFragmentPBR_Common( inputData, surfaceData);
				return color;
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
		LOD 300
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			Cull Off

			HLSLPROGRAM
			#pragma target 3.0

			#pragma multi_compile _ LOD_FADE_CROSSFADE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "../../Library/CommonLighting.hlsl"


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Diffuse_Front_ST;
			float4 _Diffuse_Back_ST;
			float4 _StarrySky_1_ST;
			float4 _Normal_Front_ST;
			float4 _Normal_Back_ST;
			float2 _StarrySky2repeatUV;
			float _Diffuse_BackMultiple;
			float _StarrySkyRotationSpeed_1;
			float _StarrySkyRotationSpeed_2;
			float _Flowswitch;
			float _Diffuse_FrontMultiple;
			CBUFFER_END
			sampler2D _Diffuse_Front;
			sampler2D _Diffuse_Back;
			sampler2D _StarrySky_1;
			sampler2D _Normal_Front;
			sampler2D _Normal_Back;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord8.xy = v.texcoord.xy;
				o.ase_texcoord8.zw = v.texcoord1.xy;
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );
				half fogFactor = 0;
				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				
				o.clipPos = positionCS;
				return o;
			}
			
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}

			half4 frag ( VertexOutput IN , bool ase_vface : SV_IsFrontFace ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 WorldNormal = normalize( IN.tSpace0.xyz );
				float3 WorldTangent = IN.tSpace1.xyz;
				float3 WorldBiTangent = IN.tSpace2.xyz;
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
	
				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float2 uv_Diffuse_Front = IN.ase_texcoord8.xy * _Diffuse_Front_ST.xy + _Diffuse_Front_ST.zw;
				float4 tex2DNode6 = tex2D( _Diffuse_Front, uv_Diffuse_Front );
				float2 uv_Diffuse_Back = IN.ase_texcoord8.xy * _Diffuse_Back_ST.xy + _Diffuse_Back_ST.zw;
				float4 switchResult158 = (((ase_vface>0)?(tex2DNode6):(( tex2D( _Diffuse_Back, uv_Diffuse_Back ) * _Diffuse_BackMultiple ))));
				float4 cloth_D_F103 = switchResult158;
				float2 uv2_StarrySky_1 = IN.ase_texcoord8.zw * _StarrySky_1_ST.xy + _StarrySky_1_ST.zw;
				float2 panner535 = ( 1.0 * _Time.y * float2( -0.02,0 ) + uv2_StarrySky_1);
				float StarrySkyRotationSpeed_1545 = _StarrySkyRotationSpeed_1;
				float2 Offset531 = ( ( 0.0 - 1 ) * WorldViewDirection.xy * StarrySkyRotationSpeed_1545 ) + panner535;
				float2 StarrySky2repeatUV549 = _StarrySky2repeatUV;
				float2 texCoord530 = IN.ase_texcoord8.zw * StarrySky2repeatUV549 + float2( 0,0 );
				float2 panner533 = ( 1.0 * _Time.y * float2( 0.03,0 ) + texCoord530);
				float StarrySkyRotationSpeed_2547 = _StarrySkyRotationSpeed_2;
				float2 Offset532 = ( ( 0.0 - 1 ) * WorldViewDirection.xy * StarrySkyRotationSpeed_2547 ) + panner533;
				float2 texCoord538 = IN.ase_texcoord8.zw * float2( 1,1 ) + float2( 0,0 );
				float Flowswitch551 = _Flowswitch;
				float4 lerpResult540 = lerp( cloth_D_F103 , ( ( tex2D( _StarrySky_1, Offset531 ) + tex2D( _StarrySky_1, Offset532 ) ) / 2.0 ) , ( tex2D( _StarrySky_1, texCoord538 ).a * Flowswitch551 ));
				float Diffuse_FrontMultiple417 = _Diffuse_FrontMultiple;
				
				float2 uv_Normal_Front = IN.ase_texcoord8.xy * _Normal_Front_ST.xy + _Normal_Front_ST.zw;
				float2 uv_Normal_Back = IN.ase_texcoord8.xy * _Normal_Back_ST.xy + _Normal_Back_ST.zw;
				float3 switchResult163 = (((ase_vface>0)?(UnpackNormalScale( tex2D( _Normal_Front, uv_Normal_Front ), 1.0f )):(UnpackNormalScale( tex2D( _Normal_Back, uv_Normal_Back ), 1.0f ))));
				float3 Normal116 = switchResult163;
				
				float cloth_A105 = tex2DNode6.a;
				
				float3 Albedo = ( lerpResult540 * Diffuse_FrontMultiple417 ).rgb;
				float3 Normal = Normal116;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = 0.5;
				float Occlusion = 1;
				float Alpha = cloth_A105;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;
				
				clip(Alpha - AlphaClipThreshold);

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
				inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				float3 SH = IN.lightmapUVOrVertexSH.xyz;
				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

				SurfaceData surfaceData;
				surfaceData.albedo              = Albedo;
				surfaceData.metallic            = saturate(Metallic);
				surfaceData.specular            = Specular;
				surfaceData.smoothness          = saturate(Smoothness),
				surfaceData.occlusion           = Occlusion,
				surfaceData.emission            = Emission,
				surfaceData.alpha               = saturate(Alpha);
				surfaceData.normalTS            = Normal;
				surfaceData.clearCoatMask       = 0;
				surfaceData.clearCoatSmoothness = 1;

				half4 color = Lighting_BlinnPhong( inputData, surfaceData);
				return color;
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
		LOD 100
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="AlphaTest" }
		
		Pass
		{
			Cull Off
			
			HLSLPROGRAM
			#pragma target 3.0

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			struct VertexInput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 uv : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _Diffuse_Front;

			VertexOutput vert ( VertexInput v )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.clipPos = TransformObjectToHClip(v.vertex.xyz);
				o.uv = v.texcoord;
				return o;
			}

			half4 frag ( VertexOutput IN ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);

				half4 color = tex2D(_Diffuse_Front, IN.uv.xy);
				clip(color.a - 0.5);
				return color;
			}

			ENDHLSL
		}
		
	}


	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	

}