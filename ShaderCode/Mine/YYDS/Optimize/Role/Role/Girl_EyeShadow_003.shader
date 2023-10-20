Shader "TA/Optimize/Role/Role/Girl_EyeShadow_003"
{
	Properties
	{
		_Diffuse_EyeShadow("Diffuse_EyeShadow", 2D) = "white" {}
		_DiffuseStrength("DiffuseStrength", Float) = 2
		_DiffuseVisibility("DiffuseVisibility", Float) = 1
		_BaseColor("BaseColor", Color) = (1,1,1,0)
		_Normal("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 1)) = 0
		_BackDepthScale("Back Depth Scale", Range( -1 , 1)) = 0
		_MaskMap("MaskMap", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_AO("AO", Float) = 1
		_EyelinerDiffuse("EyelinerDiffuse", 2D) = "white" {}
		_EyelinerColor("EyelinerColor", Color) = (1,1,1,1)
		_EyelinerStrength("EyelinerStrength", Range( 0 , 2)) = 2
		_HighlightsStrength("HighlightsStrength", Range( 0 , 1)) = 1
		_HighlightsRange("HighlightsRange", Range( 0 , 1)) = 0
		_HighlightsColor("HighlightsColor", Color) = (0,0,0,0)
		_3Sstrength("3Sstrength", Float) = 2
		_Metallic("Metallic", Range( 0 , 2)) = 0.7639677
		_3S1Color("3S1Color", Color) = (0.9811321,0,0,0)
		_3S1_01("3S1_01", Range( 0 , 1)) = 0
		_3S1_02("3S1_02", Range( 0 , 1)) = 0
		_3S1_03("3S1_03", Float) = 0
		_3S2Color("3S2Color", Color) = (0.9811321,0,0,0)
		_3S2_01("3S2_01", Range( 0 , 1)) = 0
		_3S2_02("3S2_02", Range( 0 , 1)) = 0
		_3S2_03("3S2_03", Float) = 0
		_DarkSideColor("DarkSideColor", Color) = (0.3113208,0,0,0)
		_DarkSide_02("DarkSide_02", Float) = 0
		_DarkSide_MinNew("DarkSide_MinNew", Range( -2 , 2)) = 0
		_DarkSide_MaxNew("DarkSide_MaxNew", Range( -2 , 2)) = 1
		_DarkSide_Strength("DarkSide_Strength", Range( 0 , 1)) = 0
		_SequinsNoise("SequinsNoise", 2D) = "white" {}
		_SequinsStrength("SequinsStrength", Float) = 0
		_Sequins_1Strength("Sequins_1Strength", Float) = 0
		[HDR]_Sequins_1Color("Sequins_1Color", Color) = (0.7454045,0.5583406,0.2788943,1)
		_Sequins_1Threshold("Sequins_1Threshold", Range( 0 , 1)) = 0.5
		_Sequins_1Range("Sequins_1Range", Range( 0 , 1)) = 0.2
		_Sequins_1SpakleSpeed("Sequins_1Spakle Speed", Range( 0 , 0.01)) = 0.00136
		_Sequins_1ScreenContribution("Sequins_1ScreenContribution", Range( 0 , 3)) = 0.029
		_Sequins_1Frequency("Sequins_1Frequency", Range( 0 , 10)) = 1.3
		_Sequins_2Strength("Sequins_2Strength", Float) = 0
		[HDR]_Sequins_2Color("Sequins_2Color", Color) = (0.7454045,0.5583406,0.2788943,1)
		_Sequins_2Threshold("Sequins_2Threshold", Range( 0 , 1)) = 0.5
		_Sequins_2Range("Sequins_2Range", Range( 0 , 1)) = 0.2
		_Sequins_2SpakleSpeed("Sequins_2Spakle Speed", Range( 0 , 0.01)) = 0.00136
		_Sequins_2ScreenContribution("Sequins_2ScreenContribution", Range( 0 , 3)) = 0.029
		_Sequins_2Frequency("Sequins_2Frequency", Range( 0 , 10)) = 1.3
		_SequinsAttenuation_DarkSide("SequinsAttenuation_DarkSide", Range( 2 , 6)) = 0
		_SequinsAttenuation_MinNew("SequinsAttenuation_MinNew", Range( 1 , 2)) = 0
		_SequinsAttenuation_MaxNew("SequinsAttenuation_MaxNew", Range( 1 , 2)) = 1
		_Tattoo_1("Tattoo_1", 2D) = "white" {}
		_Tattoo_1_Normal("Tattoo_1_Normal", 2D) = "bump" {}
		_Tattoo_1MaskMap("Tattoo_1MaskMap", 2D) = "white" {}
		_Tattoo_1_Strength("Tattoo_1_Strength", Float) = 4
		_Tattoo_1_Visibility("Tattoo_1_Visibility", Float) = 0
		_Tattoo_1_Smoothness("Tattoo_1_Smoothness", Range( 0 , 2)) = 0.7639677
		_Skybox_003("Skybox_003", 2D) = "white" {}
		_Tattoo_1ReflectiveIntensity("Tattoo_1ReflectiveIntensity", Range( 0 , 1)) = 0.02
	}


	SubShader
	{
		LOD 500
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		ZWrite Off
		
		Pass
		{
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha

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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Sequins_1Color;
			float4 _3S1Color;
			float4 _Tattoo_1_ST;
			float4 _Tattoo_1_Normal_ST;
			float4 _3S2Color;
			float4 _Normal_ST;
			float4 _DarkSideColor;
			float4 _HighlightsColor;
			float4 _Sequins_2Color;
			float4 _BaseColor;
			float4 _SequinsNoise_ST;
			float4 _EyelinerDiffuse_ST;
			float4 _Tattoo_1MaskMap_ST;
			float4 _EyelinerColor;
			float4 _Diffuse_EyeShadow_ST;
			float4 _MaskMap_ST;
			float _Tattoo_1ReflectiveIntensity;
			float _DiffuseStrength;
			float _3S1_01;
			float _3S1_02;
			float _Metallic;
			float _3S1_03;
			float _3S2_01;
			float _3S2_02;
			float _EyelinerStrength;
			float _HighlightsStrength;
			float _BackDepthScale;
			float _3S2_03;
			float _3Sstrength;
			float _AO;
			float _HighlightsRange;
			float _Tattoo_1_Strength;
			float _DarkSide_02;
			float _DarkSide_MaxNew;
			float _Sequins_1Threshold;
			float _Sequins_1Range;
			float _Sequins_1ScreenContribution;
			float _Sequins_1Frequency;
			float _Sequins_1SpakleSpeed;
			float _DiffuseVisibility;
			float _Tattoo_1_Visibility;
			float _Sequins_1Strength;
			float _Sequins_2Threshold;
			float _Sequins_2Range;
			float _Sequins_2ScreenContribution;
			float _Sequins_2Frequency;
			float _Sequins_2SpakleSpeed;
			float _Sequins_2Strength;
			float _NormalScale;
			float _SequinsAttenuation_MinNew;
			float _SequinsAttenuation_DarkSide;
			float _SequinsAttenuation_MaxNew;
			float _SequinsStrength;
			float _DarkSide_MinNew;
			float _Smoothness;
			float _DarkSide_Strength;
			float _Tattoo_1_Smoothness;
			CBUFFER_END
			sampler2D _SequinsNoise;
			sampler2D _MaskMap;
			sampler2D _Tattoo_1MaskMap;
			sampler2D _Normal;
			sampler2D _Tattoo_1_Normal;
			sampler2D _Tattoo_1;
			sampler2D _Diffuse_EyeShadow;
			sampler2D _Skybox_003;
			sampler2D _EyelinerDiffuse;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord8.xy = v.texcoord.xy;
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

			half4 frag ( VertexOutput IN ) : SV_Target
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
				float4 ScreenPos = IN.screenPos;

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 temp_output_456_0 = (ase_screenPosNorm).xy;
				float2 uv_SequinsNoise = IN.ase_texcoord8.xy * _SequinsNoise_ST.xy + _SequinsNoise_ST.zw;
				float2 temp_output_454_0 = ( uv_SequinsNoise * _Sequins_1Frequency );
				float mulTime450 = _TimeParameters.x * _Sequins_1SpakleSpeed;
				float smoothstepResult462 = smoothstep( _Sequins_1Threshold , ( _Sequins_1Threshold + _Sequins_1Range ) , ( tex2D( _SequinsNoise, ( ( temp_output_456_0 * _Sequins_1ScreenContribution ) + temp_output_454_0 + mulTime450 ) ).g * tex2D( _SequinsNoise, ( ( temp_output_454_0 * 1.1 ) + -mulTime450 ) ).g ));
				float DiffuseVisibility662 = _DiffuseVisibility;
				float2 uv_MaskMap = IN.ase_texcoord8.xy * _MaskMap_ST.xy + _MaskMap_ST.zw;
				float4 tex2DNode524 = tex2D( _MaskMap, uv_MaskMap );
				float2 uv_Tattoo_1MaskMap = IN.ase_texcoord8.xy * _Tattoo_1MaskMap_ST.xy + _Tattoo_1MaskMap_ST.zw;
				float4 tex2DNode531 = tex2D( _Tattoo_1MaskMap, uv_Tattoo_1MaskMap );
				float Tattoo_1_Visibility659 = _Tattoo_1_Visibility;
				float SequinsMask567 = saturate( ( ( DiffuseVisibility662 * tex2DNode524.a ) + ( tex2DNode531.a * Tattoo_1_Visibility659 ) ) );
				float2 temp_output_605_0 = ( uv_SequinsNoise * _Sequins_2Frequency );
				float mulTime599 = _TimeParameters.x * _Sequins_2SpakleSpeed;
				float smoothstepResult613 = smoothstep( _Sequins_2Threshold , ( _Sequins_2Threshold + _Sequins_2Range ) , ( tex2D( _SequinsNoise, ( ( temp_output_456_0 * _Sequins_2ScreenContribution ) + temp_output_605_0 + mulTime599 ) ).g * tex2D( _SequinsNoise, ( ( temp_output_605_0 * 1.1 ) + -mulTime599 ) ).g ));
				float2 uv_Normal = IN.ase_texcoord8.xy * _Normal_ST.xy + _Normal_ST.zw;
				float3 unpack59 = UnpackNormalScale( tex2D( _Normal, uv_Normal ), _NormalScale );
				unpack59.z = lerp( 1, unpack59.z, saturate(_NormalScale) );
				float2 uv_Tattoo_1_Normal = IN.ase_texcoord8.xy * _Tattoo_1_Normal_ST.xy + _Tattoo_1_Normal_ST.zw;
				float3 unpack436 = UnpackNormalScale( tex2D( _Tattoo_1_Normal, uv_Tattoo_1_Normal ), _NormalScale );
				unpack436.z = lerp( 1, unpack436.z, saturate(_NormalScale) );
				float2 uv_Tattoo_1 = IN.ase_texcoord8.xy * _Tattoo_1_ST.xy + _Tattoo_1_ST.zw;
				float4 tex2DNode472 = tex2D( _Tattoo_1, uv_Tattoo_1 );
				float Tattoo_1_A474 = ( tex2DNode472.a * Tattoo_1_Visibility659 );
				float Tattoo_1_A_if1536 =  ( Tattoo_1_A474 - 0.0 > 0.0 ? 1.0 : Tattoo_1_A474 - 0.0 <= 0.0 && Tattoo_1_A474 + 0.0 >= 0.0 ? 0.0 : 0.0 ) ;
				float3 lerpResult434 = lerp( unpack59 , unpack436 , Tattoo_1_A_if1536);
				float3 worldNormal78 = lerpResult434;
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal243 = worldNormal78;
				float3 worldNormal243 = normalize( float3(dot(tanToWorld0,tanNormal243), dot(tanToWorld1,tanNormal243), dot(tanToWorld2,tanNormal243)) );
				float dotResult245 = dot( worldNormal243 , _MainLightPosition.xyz );
				float LightS287 = dotResult245;
				float4 Sequins440 = ( ( ( _Sequins_1Color * smoothstepResult462 * SequinsMask567 * _Sequins_1Strength ) + ( _Sequins_2Color * smoothstepResult613 * SequinsMask567 * _Sequins_2Strength ) ) * saturate( -(_SequinsAttenuation_MinNew + ((LightS287*( 1.0 + _SequinsAttenuation_MinNew ) + _SequinsAttenuation_DarkSide) - 0.0) * (_SequinsAttenuation_MaxNew - _SequinsAttenuation_MinNew) / (1.0 - 0.0)) ) * _SequinsStrength );
				float3 tanNormal334 = worldNormal78;
				float3 worldNormal334 = normalize( float3(dot(tanToWorld0,tanNormal334), dot(tanToWorld1,tanNormal334), dot(tanToWorld2,tanNormal334)) );
				float dotResult301 = dot( worldNormal334 , _MainLightPosition.xyz );
				float4 DarkSideColor401 = saturate( ( (_DarkSide_MinNew + ((dotResult301*( 1.0 + _DarkSide_MinNew ) + _DarkSide_02) - 0.0) * (_DarkSide_MaxNew - _DarkSide_MinNew) / (1.0 - 0.0)) + _DarkSideColor + _DarkSide_Strength ) );
				float2 uv_Diffuse_EyeShadow = IN.ase_texcoord8.xy * _Diffuse_EyeShadow_ST.xy + _Diffuse_EyeShadow_ST.zw;
				float4 tex2DNode259 = tex2D( _Diffuse_EyeShadow, uv_Diffuse_EyeShadow );
				float4 Diffuse261 = tex2DNode259;
				float4 SSSColor_01349 = saturate( ( ( 1.0 - saturate( (LightS287*_3S1_01 + _3S1_02) ) ) * _3S1Color * _3S1_03 ) );
				float4 SSSColor_02347 = ( ( 1.0 - saturate( (LightS287*_3S2_01 + _3S2_02) ) ) * _3S2Color * _3S2_03 );
				float MaskMap_3S523 = tex2DNode524.g;
				float4 temp_output_283_0 = ( ( Diffuse261 * _DiffuseStrength ) + ( ( SSSColor_01349 + SSSColor_02347 ) * MaskMap_3S523 * _3Sstrength ) );
				float MaskMap_AO528 = saturate( ( tex2DNode524.b + tex2DNode531.b ) );
				float4 lerpResult369 = lerp( temp_output_283_0 , ( temp_output_283_0 * MaskMap_AO528 ) , _AO);
				float3 normalizeResult265 = normalize( ( WorldViewDirection + _MainLightPosition.xyz ) );
				float3 tanNormal266 = worldNormal78;
				float3 worldNormal266 = normalize( float3(dot(tanToWorld0,tanNormal266), dot(tanToWorld1,tanNormal266), dot(tanToWorld2,tanNormal266)) );
				float dotResult267 = dot( normalizeResult265 , worldNormal266 );
				float4 Specilar276 = saturate( ( pow( saturate( dotResult267 ) , exp2( ( ( _HighlightsRange * 10.0 ) + 1.0 ) ) ) * _HighlightsColor * _HighlightsStrength ) );
				float4 temp_output_284_0 = ( ( DarkSideColor401 * lerpResult369 * _BaseColor ) + Specilar276 );
				float2 texCoord484 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float2 Offset485 = ( ( 0.0 - 1 ) * ( WorldViewDirection.xy / WorldViewDirection.z ) * 0.5 ) + texCoord484;
				float2 Offset483 = ( ( 0.0 - 1 ) * WorldViewDirection.xy * _BackDepthScale ) + Offset485;
				float4 Tattoo_1Reflective489 = ( tex2D( _Skybox_003, Offset483 ) * _Tattoo_1ReflectiveIntensity );
				float4 lerpResult477 = lerp( temp_output_284_0 , ( ( tex2DNode472 * _Tattoo_1_Strength ) + Tattoo_1Reflective489 ) , Tattoo_1_A474);
				float4 lerpResult541 = lerp( temp_output_284_0 , lerpResult477 , Tattoo_1_A474);
				float2 uv_EyelinerDiffuse = IN.ase_texcoord8.xy * _EyelinerDiffuse_ST.xy + _EyelinerDiffuse_ST.zw;
				float4 tex2DNode494 = tex2D( _EyelinerDiffuse, uv_EyelinerDiffuse );
				float4 Eyeliner497 = ( _EyelinerColor * tex2DNode494 );
				float temp_output_501_0 = ( tex2DNode494.a * _EyelinerStrength );
				float EyelinerA1500 = ( _EyelinerColor.a * temp_output_501_0 );
				float4 lerpResult546 = lerp( ( Sequins440 + lerpResult541 ) , Eyeliner497 , EyelinerA1500);
				
				float lerpResult530 = lerp( _Metallic , tex2DNode531.g , Tattoo_1_A474);
				float Tattoo_1_M515 = lerpResult530;
				
				float lerpResult522 = lerp( ( tex2DNode524.r * _Smoothness ) , ( _Tattoo_1_Smoothness * tex2DNode531.r ) , Tattoo_1_A474);
				float MaskMap_S526 = lerpResult522;
				
				float EyeShadowA492 = tex2DNode259.a;
				float EyelinerA495 = tex2DNode494.a;
				
				float3 Albedo = lerpResult546.rgb;
				float3 Normal = worldNormal78;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = Tattoo_1_M515;
				float Smoothness = MaskMap_S526;
				float Occlusion = 1;
				float Alpha = saturate( ( ( EyeShadowA492 * DiffuseVisibility662 ) + EyelinerA495 + Tattoo_1_A474 ) );
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;
				
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
	}
	

	SubShader
	{
		LOD 300
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		ZWrite Off
		
		Pass
		{
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha

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
				float4 screenPos : TEXCOORD6;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Sequins_1Color;
			float4 _3S1Color;
			float4 _Tattoo_1_ST;
			float4 _Tattoo_1_Normal_ST;
			float4 _3S2Color;
			float4 _Normal_ST;
			float4 _DarkSideColor;
			float4 _HighlightsColor;
			float4 _Sequins_2Color;
			float4 _BaseColor;
			float4 _SequinsNoise_ST;
			float4 _EyelinerDiffuse_ST;
			float4 _Tattoo_1MaskMap_ST;
			float4 _EyelinerColor;
			float4 _Diffuse_EyeShadow_ST;
			float4 _MaskMap_ST;
			float _Tattoo_1ReflectiveIntensity;
			float _DiffuseStrength;
			float _3S1_01;
			float _3S1_02;
			float _Metallic;
			float _3S1_03;
			float _3S2_01;
			float _3S2_02;
			float _EyelinerStrength;
			float _HighlightsStrength;
			float _BackDepthScale;
			float _3S2_03;
			float _3Sstrength;
			float _AO;
			float _HighlightsRange;
			float _Tattoo_1_Strength;
			float _DarkSide_02;
			float _DarkSide_MaxNew;
			float _Sequins_1Threshold;
			float _Sequins_1Range;
			float _Sequins_1ScreenContribution;
			float _Sequins_1Frequency;
			float _Sequins_1SpakleSpeed;
			float _DiffuseVisibility;
			float _Tattoo_1_Visibility;
			float _Sequins_1Strength;
			float _Sequins_2Threshold;
			float _Sequins_2Range;
			float _Sequins_2ScreenContribution;
			float _Sequins_2Frequency;
			float _Sequins_2SpakleSpeed;
			float _Sequins_2Strength;
			float _NormalScale;
			float _SequinsAttenuation_MinNew;
			float _SequinsAttenuation_DarkSide;
			float _SequinsAttenuation_MaxNew;
			float _SequinsStrength;
			float _DarkSide_MinNew;
			float _Smoothness;
			float _DarkSide_Strength;
			float _Tattoo_1_Smoothness;
			CBUFFER_END
			sampler2D _SequinsNoise;
			sampler2D _MaskMap;
			sampler2D _Tattoo_1MaskMap;
			sampler2D _Normal;
			sampler2D _Tattoo_1_Normal;
			sampler2D _Tattoo_1;
			sampler2D _Diffuse_EyeShadow;
			sampler2D _Skybox_003;
			sampler2D _EyelinerDiffuse;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord8.xy = v.texcoord.xy;
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

			half4 frag ( VertexOutput IN ) : SV_Target
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
				float4 ScreenPos = IN.screenPos;

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 temp_output_456_0 = (ase_screenPosNorm).xy;
				float2 uv_SequinsNoise = IN.ase_texcoord8.xy * _SequinsNoise_ST.xy + _SequinsNoise_ST.zw;
				float2 temp_output_454_0 = ( uv_SequinsNoise * _Sequins_1Frequency );
				float mulTime450 = _TimeParameters.x * _Sequins_1SpakleSpeed;
				float smoothstepResult462 = smoothstep( _Sequins_1Threshold , ( _Sequins_1Threshold + _Sequins_1Range ) , ( tex2D( _SequinsNoise, ( ( temp_output_456_0 * _Sequins_1ScreenContribution ) + temp_output_454_0 + mulTime450 ) ).g * tex2D( _SequinsNoise, ( ( temp_output_454_0 * 1.1 ) + -mulTime450 ) ).g ));
				float DiffuseVisibility662 = _DiffuseVisibility;
				float2 uv_MaskMap = IN.ase_texcoord8.xy * _MaskMap_ST.xy + _MaskMap_ST.zw;
				float4 tex2DNode524 = tex2D( _MaskMap, uv_MaskMap );
				float2 uv_Tattoo_1MaskMap = IN.ase_texcoord8.xy * _Tattoo_1MaskMap_ST.xy + _Tattoo_1MaskMap_ST.zw;
				float4 tex2DNode531 = tex2D( _Tattoo_1MaskMap, uv_Tattoo_1MaskMap );
				float Tattoo_1_Visibility659 = _Tattoo_1_Visibility;
				float SequinsMask567 = saturate( ( ( DiffuseVisibility662 * tex2DNode524.a ) + ( tex2DNode531.a * Tattoo_1_Visibility659 ) ) );
				float2 temp_output_605_0 = ( uv_SequinsNoise * _Sequins_2Frequency );
				float mulTime599 = _TimeParameters.x * _Sequins_2SpakleSpeed;
				float smoothstepResult613 = smoothstep( _Sequins_2Threshold , ( _Sequins_2Threshold + _Sequins_2Range ) , ( tex2D( _SequinsNoise, ( ( temp_output_456_0 * _Sequins_2ScreenContribution ) + temp_output_605_0 + mulTime599 ) ).g * tex2D( _SequinsNoise, ( ( temp_output_605_0 * 1.1 ) + -mulTime599 ) ).g ));
				float2 uv_Normal = IN.ase_texcoord8.xy * _Normal_ST.xy + _Normal_ST.zw;
				float3 unpack59 = UnpackNormalScale( tex2D( _Normal, uv_Normal ), _NormalScale );
				unpack59.z = lerp( 1, unpack59.z, saturate(_NormalScale) );
				float2 uv_Tattoo_1_Normal = IN.ase_texcoord8.xy * _Tattoo_1_Normal_ST.xy + _Tattoo_1_Normal_ST.zw;
				float3 unpack436 = UnpackNormalScale( tex2D( _Tattoo_1_Normal, uv_Tattoo_1_Normal ), _NormalScale );
				unpack436.z = lerp( 1, unpack436.z, saturate(_NormalScale) );
				float2 uv_Tattoo_1 = IN.ase_texcoord8.xy * _Tattoo_1_ST.xy + _Tattoo_1_ST.zw;
				float4 tex2DNode472 = tex2D( _Tattoo_1, uv_Tattoo_1 );
				float Tattoo_1_A474 = ( tex2DNode472.a * Tattoo_1_Visibility659 );
				float Tattoo_1_A_if1536 =  ( Tattoo_1_A474 - 0.0 > 0.0 ? 1.0 : Tattoo_1_A474 - 0.0 <= 0.0 && Tattoo_1_A474 + 0.0 >= 0.0 ? 0.0 : 0.0 ) ;
				float3 lerpResult434 = lerp( unpack59 , unpack436 , Tattoo_1_A_if1536);
				float3 worldNormal78 = lerpResult434;
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal243 = worldNormal78;
				float3 worldNormal243 = normalize( float3(dot(tanToWorld0,tanNormal243), dot(tanToWorld1,tanNormal243), dot(tanToWorld2,tanNormal243)) );
				float dotResult245 = dot( worldNormal243 , _MainLightPosition.xyz );
				float LightS287 = dotResult245;
				float4 Sequins440 = ( ( ( _Sequins_1Color * smoothstepResult462 * SequinsMask567 * _Sequins_1Strength ) + ( _Sequins_2Color * smoothstepResult613 * SequinsMask567 * _Sequins_2Strength ) ) * saturate( -(_SequinsAttenuation_MinNew + ((LightS287*( 1.0 + _SequinsAttenuation_MinNew ) + _SequinsAttenuation_DarkSide) - 0.0) * (_SequinsAttenuation_MaxNew - _SequinsAttenuation_MinNew) / (1.0 - 0.0)) ) * _SequinsStrength );
				float3 tanNormal334 = worldNormal78;
				float3 worldNormal334 = normalize( float3(dot(tanToWorld0,tanNormal334), dot(tanToWorld1,tanNormal334), dot(tanToWorld2,tanNormal334)) );
				float dotResult301 = dot( worldNormal334 , _MainLightPosition.xyz );
				float4 DarkSideColor401 = saturate( ( (_DarkSide_MinNew + ((dotResult301*( 1.0 + _DarkSide_MinNew ) + _DarkSide_02) - 0.0) * (_DarkSide_MaxNew - _DarkSide_MinNew) / (1.0 - 0.0)) + _DarkSideColor + _DarkSide_Strength ) );
				float2 uv_Diffuse_EyeShadow = IN.ase_texcoord8.xy * _Diffuse_EyeShadow_ST.xy + _Diffuse_EyeShadow_ST.zw;
				float4 tex2DNode259 = tex2D( _Diffuse_EyeShadow, uv_Diffuse_EyeShadow );
				float4 Diffuse261 = tex2DNode259;
				float4 SSSColor_01349 = saturate( ( ( 1.0 - saturate( (LightS287*_3S1_01 + _3S1_02) ) ) * _3S1Color * _3S1_03 ) );
				float4 SSSColor_02347 = ( ( 1.0 - saturate( (LightS287*_3S2_01 + _3S2_02) ) ) * _3S2Color * _3S2_03 );
				float MaskMap_3S523 = tex2DNode524.g;
				float4 temp_output_283_0 = ( ( Diffuse261 * _DiffuseStrength ) + ( ( SSSColor_01349 + SSSColor_02347 ) * MaskMap_3S523 * _3Sstrength ) );
				float MaskMap_AO528 = saturate( ( tex2DNode524.b + tex2DNode531.b ) );
				float4 lerpResult369 = lerp( temp_output_283_0 , ( temp_output_283_0 * MaskMap_AO528 ) , _AO);
				float3 normalizeResult265 = normalize( ( WorldViewDirection + _MainLightPosition.xyz ) );
				float3 tanNormal266 = worldNormal78;
				float3 worldNormal266 = normalize( float3(dot(tanToWorld0,tanNormal266), dot(tanToWorld1,tanNormal266), dot(tanToWorld2,tanNormal266)) );
				float dotResult267 = dot( normalizeResult265 , worldNormal266 );
				float4 Specilar276 = saturate( ( pow( saturate( dotResult267 ) , exp2( ( ( _HighlightsRange * 10.0 ) + 1.0 ) ) ) * _HighlightsColor * _HighlightsStrength ) );
				float4 temp_output_284_0 = ( ( DarkSideColor401 * lerpResult369 * _BaseColor ) + Specilar276 );
				float2 texCoord484 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float2 Offset485 = ( ( 0.0 - 1 ) * ( WorldViewDirection.xy / WorldViewDirection.z ) * 0.5 ) + texCoord484;
				float2 Offset483 = ( ( 0.0 - 1 ) * WorldViewDirection.xy * _BackDepthScale ) + Offset485;
				float4 Tattoo_1Reflective489 = ( tex2D( _Skybox_003, Offset483 ) * _Tattoo_1ReflectiveIntensity );
				float4 lerpResult477 = lerp( temp_output_284_0 , ( ( tex2DNode472 * _Tattoo_1_Strength ) + Tattoo_1Reflective489 ) , Tattoo_1_A474);
				float4 lerpResult541 = lerp( temp_output_284_0 , lerpResult477 , Tattoo_1_A474);
				float2 uv_EyelinerDiffuse = IN.ase_texcoord8.xy * _EyelinerDiffuse_ST.xy + _EyelinerDiffuse_ST.zw;
				float4 tex2DNode494 = tex2D( _EyelinerDiffuse, uv_EyelinerDiffuse );
				float4 Eyeliner497 = ( _EyelinerColor * tex2DNode494 );
				float temp_output_501_0 = ( tex2DNode494.a * _EyelinerStrength );
				float EyelinerA1500 = ( _EyelinerColor.a * temp_output_501_0 );
				float4 lerpResult546 = lerp( ( Sequins440 + lerpResult541 ) , Eyeliner497 , EyelinerA1500);
				
				float lerpResult530 = lerp( _Metallic , tex2DNode531.g , Tattoo_1_A474);
				float Tattoo_1_M515 = lerpResult530;
				
				float lerpResult522 = lerp( ( tex2DNode524.r * _Smoothness ) , ( _Tattoo_1_Smoothness * tex2DNode531.r ) , Tattoo_1_A474);
				float MaskMap_S526 = lerpResult522;
				
				float EyeShadowA492 = tex2DNode259.a;
				float EyelinerA495 = tex2DNode494.a;
				
				float3 Albedo = lerpResult546.rgb;
				float3 Normal = worldNormal78;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = Tattoo_1_M515;
				float Smoothness = MaskMap_S526;
				float Occlusion = 1;
				float Alpha = saturate( ( ( EyeShadowA492 * DiffuseVisibility662 ) + EyelinerA495 + Tattoo_1_A474 ) );
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;
				
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
	}

	
	SubShader
	{
		LOD 100
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			
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

			sampler2D _Diffuse_EyeShadow;

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

				half4 color = tex2D(_Diffuse_EyeShadow, IN.uv.xy);
				return color;
			}

			ENDHLSL
		}
		
	}


	FallBack "Hidden/Universal Render Pipeline/FallbackError"
}