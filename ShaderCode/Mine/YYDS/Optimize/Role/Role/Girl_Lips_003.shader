Shader "TA/Optimize/Role/Role/Girl_Lips_003"
{
	Properties
	{
		_Diffuse_EyeShadow("Diffuse_EyeShadow", 2D) = "white" {}
		_DiffuseStrength("DiffuseStrength", Float) = 2
		_DiffuseVisibility("DiffuseVisibility", Float) = 1
		_BaseColor("BaseColor", Color) = (1,1,1,0)
		_Normal("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 1)) = 0
		_MaskMap("MaskMap", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Float0("Float 0", Range( 0 , 1.5)) = 1.107643
		_AO("AO", Float) = 1
		_HighlightsStrength("HighlightsStrength", Range( 0 , 1)) = 1
		_HighlightsRange("HighlightsRange", Range( 0 , 1)) = 0
		_HighlightsColor("HighlightsColor", Color) = (0,0,0,0)
		_3Sstrength("3Sstrength", Float) = 2
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
		_Highlight("Highlight", CUBE) = "white" {}
		_HighlightColor("HighlightColor", Color) = (1,1,1,0)
		_HighlightStrength("HighlightStrength", Float) = 0.3
		_Highlight_2("Highlight_2", Vector) = (1,1,-1,0)
		_SequinsNoise("SequinsNoise", 2D) = "white" {}
		_SequinsMask("SequinsMask", 2D) = "white" {}
		_SequinsStrength("SequinsStrength", Float) = 0
		[HDR]_SequinsColor("SequinsColor", Color) = (0.7454045,0.5583406,0.2788943,1)
		_Threshold("Threshold", Range( 0 , 1)) = 0.5
		_Range("Range", Range( 0 , 1)) = 0.2
		_SequinsSpakleSpeed("SequinsSpakle Speed", Range( 0 , 0.01)) = 0.00136
		_SequinsScreenContribution("SequinsScreenContribution", Range( 0 , 1)) = 0.029
		_SequinsFrequency("SequinsFrequency", Range( 0 , 10)) = 1.3
	}


	SubShader
	{
		LOD 500
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Pass
		{
			Tags { "LightMode"="UniversalForward" }
			ZWrite Off
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
			float4 _Normal_ST;
			float4 _BaseColor;
			float4 _HighlightsColor;
			float4 _3S1Color;
			float4 _SequinsColor;
			float4 _Diffuse_EyeShadow_ST;
			float4 _3S2Color;
			float4 _SequinsNoise_ST;
			float4 _DarkSideColor;
			float4 _HighlightColor;
			float4 _MaskMap_ST;
			float4 _SequinsMask_ST;
			float3 _Highlight_2;
			float _SequinsScreenContribution;
			float _Range;
			float _SequinsSpakleSpeed;
			float _Threshold;
			float _HighlightsStrength;
			float _HighlightsRange;
			float _SequinsStrength;
			float _SequinsFrequency;
			float _AO;
			float _3S2_02;
			float _3S2_03;
			float _Smoothness;
			float _3S2_01;
			float _3S1_03;
			float _3S1_02;
			float _3S1_01;
			float _DiffuseStrength;
			float _DarkSide_Strength;
			float _DarkSide_MaxNew;
			float _DarkSide_02;
			float _DarkSide_MinNew;
			float _HighlightStrength;
			float _Float0;
			float _NormalScale;
			float _3Sstrength;
			float _DiffuseVisibility;
			CBUFFER_END
			samplerCUBE _Highlight;
			sampler2D _Normal;
			sampler2D _MaskMap;
			sampler2D _Diffuse_EyeShadow;
			sampler2D _SequinsNoise;
			sampler2D _SequinsMask;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord8.xyz = v.texcoord.xyz;
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

				float2 uv_Normal = IN.ase_texcoord8.xyz.xy * _Normal_ST.xy + _Normal_ST.zw;
				float3 unpack59 = UnpackNormalScale( tex2D( _Normal, uv_Normal ), _NormalScale );
				unpack59.z = lerp( 1, unpack59.z, saturate(_NormalScale) );
				float3 Normal78 = unpack59;
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 worldRefl565 = reflect( -WorldViewDirection, float3( dot( tanToWorld0, Normal78 ), dot( tanToWorld1, Normal78 ), dot( tanToWorld2, Normal78 ) ) );
				float3 _Vector0 = float3(0.75,0.75,0.75);
				float3 appendResult563 = (float3(_Vector0.x , _Vector0.y , ( _Vector0.z + (0.0 + (( 1.0 - _Float0 ) - 0.0) * (2.0 - 0.0) / (1.0 - 0.0)) )));
				float2 uv_MaskMap = IN.ase_texcoord8.xyz.xy * _MaskMap_ST.xy + _MaskMap_ST.zw;
				float4 tex2DNode524 = tex2D( _MaskMap, uv_MaskMap );
				float MaskMap_3S523 = tex2DNode524.g;
				float4 Reflective489 = ( texCUBE( _Highlight, ( ( (float3( -0.75,-0.75,-0.75 ) + (worldRefl565 - float3( 0,0,0 )) * (float3( 0.75,0.75,0.75 ) - float3( -0.75,-0.75,-0.75 )) / (float3( 1,1,1 ) - float3( 0,0,0 ))) + appendResult563 ) * _Highlight_2 ) ) * _Float0 * MaskMap_3S523 * _HighlightStrength * _HighlightColor );
				float3 tanNormal334 = Normal78;
				float3 worldNormal334 = normalize( float3(dot(tanToWorld0,tanNormal334), dot(tanToWorld1,tanNormal334), dot(tanToWorld2,tanNormal334)) );
				float dotResult301 = dot( worldNormal334 , _MainLightPosition.xyz );
				float4 DarkSideColor401 = saturate( ( (_DarkSide_MinNew + ((dotResult301*( 1.0 + _DarkSide_MinNew ) + _DarkSide_02) - 0.0) * (_DarkSide_MaxNew - _DarkSide_MinNew) / (1.0 - 0.0)) + _DarkSideColor + _DarkSide_Strength ) );
				float2 uv_Diffuse_EyeShadow = IN.ase_texcoord8.xyz.xy * _Diffuse_EyeShadow_ST.xy + _Diffuse_EyeShadow_ST.zw;
				float4 tex2DNode259 = tex2D( _Diffuse_EyeShadow, uv_Diffuse_EyeShadow );
				float4 Diffuse261 = tex2DNode259;
				float3 tanNormal243 = Normal78;
				float3 worldNormal243 = normalize( float3(dot(tanToWorld0,tanNormal243), dot(tanToWorld1,tanNormal243), dot(tanToWorld2,tanNormal243)) );
				float dotResult245 = dot( worldNormal243 , _MainLightPosition.xyz );
				float LightS287 = dotResult245;
				float4 SSSColor_01349 = saturate( ( ( 1.0 - saturate( (LightS287*_3S1_01 + _3S1_02) ) ) * _3S1Color * _3S1_03 ) );
				float4 SSSColor_02347 = ( ( 1.0 - saturate( (LightS287*_3S2_01 + _3S2_02) ) ) * _3S2Color * _3S2_03 );
				float4 temp_output_283_0 = ( ( Diffuse261 * _DiffuseStrength ) + ( ( SSSColor_01349 + SSSColor_02347 ) * MaskMap_3S523 * _3Sstrength ) );
				float MaskMap_AO528 = tex2DNode524.b;
				float4 lerpResult369 = lerp( temp_output_283_0 , ( temp_output_283_0 * MaskMap_AO528 ) , _AO);
				float3 normalizeResult265 = normalize( ( WorldViewDirection + _MainLightPosition.xyz ) );
				float3 tanNormal266 = Normal78;
				float3 worldNormal266 = normalize( float3(dot(tanToWorld0,tanNormal266), dot(tanToWorld1,tanNormal266), dot(tanToWorld2,tanNormal266)) );
				float dotResult267 = dot( normalizeResult265 , worldNormal266 );
				float4 Specilar276 = saturate( ( pow( saturate( dotResult267 ) , exp2( ( ( _HighlightsRange * 10.0 ) + 1.0 ) ) ) * _HighlightsColor * _HighlightsStrength ) );
				float4 temp_output_284_0 = ( ( DarkSideColor401 * lerpResult369 * _BaseColor ) + Specilar276 );
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 uv_SequinsNoise = IN.ase_texcoord8.xyz.xy * _SequinsNoise_ST.xy + _SequinsNoise_ST.zw;
				float2 temp_output_454_0 = ( uv_SequinsNoise * _SequinsFrequency );
				float mulTime450 = _TimeParameters.x * _SequinsSpakleSpeed;
				float smoothstepResult462 = smoothstep( _Threshold , ( _Threshold + _Range ) , ( tex2D( _SequinsNoise, ( ( (ase_screenPosNorm).xy * _SequinsScreenContribution ) + temp_output_454_0 + mulTime450 ) ).g * tex2D( _SequinsNoise, ( ( temp_output_454_0 * 1.1 ) + -mulTime450 ) ).g ));
				float2 uv_SequinsMask = IN.ase_texcoord8.xyz.xy * _SequinsMask_ST.xy + _SequinsMask_ST.zw;
				float4 Sequins440 = ( _SequinsColor * smoothstepResult462 * tex2D( _SequinsMask, uv_SequinsMask ).r );
				float4 lerpResult541 = lerp( temp_output_284_0 , ( temp_output_284_0 + Sequins440 ) , _SequinsStrength);
				
				float MaskMap_S526 = ( 0.0 * _Smoothness );
				
				float EyeShadowA492 = tex2DNode259.a;
				
				float3 Albedo = ( Reflective489 + lerpResult541 ).rgb;
				float3 Normal = Normal78;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = MaskMap_S526;
				float Occlusion = 1;
				float Alpha = saturate( ( EyeShadowA492 * _DiffuseVisibility ) );
				float AlphaClipThreshold = 0.5;
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
		
		Pass
		{
			Tags { "LightMode"="UniversalForward" }
			ZWrite Off
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
			float4 _Normal_ST;
			float4 _BaseColor;
			float4 _HighlightsColor;
			float4 _3S1Color;
			float4 _SequinsColor;
			float4 _Diffuse_EyeShadow_ST;
			float4 _3S2Color;
			float4 _SequinsNoise_ST;
			float4 _DarkSideColor;
			float4 _HighlightColor;
			float4 _MaskMap_ST;
			float4 _SequinsMask_ST;
			float3 _Highlight_2;
			float _SequinsScreenContribution;
			float _Range;
			float _SequinsSpakleSpeed;
			float _Threshold;
			float _HighlightsStrength;
			float _HighlightsRange;
			float _SequinsStrength;
			float _SequinsFrequency;
			float _AO;
			float _3S2_02;
			float _3S2_03;
			float _Smoothness;
			float _3S2_01;
			float _3S1_03;
			float _3S1_02;
			float _3S1_01;
			float _DiffuseStrength;
			float _DarkSide_Strength;
			float _DarkSide_MaxNew;
			float _DarkSide_02;
			float _DarkSide_MinNew;
			float _HighlightStrength;
			float _Float0;
			float _NormalScale;
			float _3Sstrength;
			float _DiffuseVisibility;
			CBUFFER_END
			samplerCUBE _Highlight;
			sampler2D _Normal;
			sampler2D _MaskMap;
			sampler2D _Diffuse_EyeShadow;
			sampler2D _SequinsNoise;
			sampler2D _SequinsMask;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord8.xyz = v.texcoord.xyz;
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

				float2 uv_Normal = IN.ase_texcoord8.xyz.xy * _Normal_ST.xy + _Normal_ST.zw;
				float3 unpack59 = UnpackNormalScale( tex2D( _Normal, uv_Normal ), _NormalScale );
				unpack59.z = lerp( 1, unpack59.z, saturate(_NormalScale) );
				float3 Normal78 = unpack59;
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 worldRefl565 = reflect( -WorldViewDirection, float3( dot( tanToWorld0, Normal78 ), dot( tanToWorld1, Normal78 ), dot( tanToWorld2, Normal78 ) ) );
				float3 _Vector0 = float3(0.75,0.75,0.75);
				float3 appendResult563 = (float3(_Vector0.x , _Vector0.y , ( _Vector0.z + (0.0 + (( 1.0 - _Float0 ) - 0.0) * (2.0 - 0.0) / (1.0 - 0.0)) )));
				float2 uv_MaskMap = IN.ase_texcoord8.xyz.xy * _MaskMap_ST.xy + _MaskMap_ST.zw;
				float4 tex2DNode524 = tex2D( _MaskMap, uv_MaskMap );
				float MaskMap_3S523 = tex2DNode524.g;
				float4 Reflective489 = ( texCUBE( _Highlight, ( ( (float3( -0.75,-0.75,-0.75 ) + (worldRefl565 - float3( 0,0,0 )) * (float3( 0.75,0.75,0.75 ) - float3( -0.75,-0.75,-0.75 )) / (float3( 1,1,1 ) - float3( 0,0,0 ))) + appendResult563 ) * _Highlight_2 ) ) * _Float0 * MaskMap_3S523 * _HighlightStrength * _HighlightColor );
				float3 tanNormal334 = Normal78;
				float3 worldNormal334 = normalize( float3(dot(tanToWorld0,tanNormal334), dot(tanToWorld1,tanNormal334), dot(tanToWorld2,tanNormal334)) );
				float dotResult301 = dot( worldNormal334 , _MainLightPosition.xyz );
				float4 DarkSideColor401 = saturate( ( (_DarkSide_MinNew + ((dotResult301*( 1.0 + _DarkSide_MinNew ) + _DarkSide_02) - 0.0) * (_DarkSide_MaxNew - _DarkSide_MinNew) / (1.0 - 0.0)) + _DarkSideColor + _DarkSide_Strength ) );
				float2 uv_Diffuse_EyeShadow = IN.ase_texcoord8.xyz.xy * _Diffuse_EyeShadow_ST.xy + _Diffuse_EyeShadow_ST.zw;
				float4 tex2DNode259 = tex2D( _Diffuse_EyeShadow, uv_Diffuse_EyeShadow );
				float4 Diffuse261 = tex2DNode259;
				float3 tanNormal243 = Normal78;
				float3 worldNormal243 = normalize( float3(dot(tanToWorld0,tanNormal243), dot(tanToWorld1,tanNormal243), dot(tanToWorld2,tanNormal243)) );
				float dotResult245 = dot( worldNormal243 , _MainLightPosition.xyz );
				float LightS287 = dotResult245;
				float4 SSSColor_01349 = saturate( ( ( 1.0 - saturate( (LightS287*_3S1_01 + _3S1_02) ) ) * _3S1Color * _3S1_03 ) );
				float4 SSSColor_02347 = ( ( 1.0 - saturate( (LightS287*_3S2_01 + _3S2_02) ) ) * _3S2Color * _3S2_03 );
				float4 temp_output_283_0 = ( ( Diffuse261 * _DiffuseStrength ) + ( ( SSSColor_01349 + SSSColor_02347 ) * MaskMap_3S523 * _3Sstrength ) );
				float MaskMap_AO528 = tex2DNode524.b;
				float4 lerpResult369 = lerp( temp_output_283_0 , ( temp_output_283_0 * MaskMap_AO528 ) , _AO);
				float3 normalizeResult265 = normalize( ( WorldViewDirection + _MainLightPosition.xyz ) );
				float3 tanNormal266 = Normal78;
				float3 worldNormal266 = normalize( float3(dot(tanToWorld0,tanNormal266), dot(tanToWorld1,tanNormal266), dot(tanToWorld2,tanNormal266)) );
				float dotResult267 = dot( normalizeResult265 , worldNormal266 );
				float4 Specilar276 = saturate( ( pow( saturate( dotResult267 ) , exp2( ( ( _HighlightsRange * 10.0 ) + 1.0 ) ) ) * _HighlightsColor * _HighlightsStrength ) );
				float4 temp_output_284_0 = ( ( DarkSideColor401 * lerpResult369 * _BaseColor ) + Specilar276 );
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 uv_SequinsNoise = IN.ase_texcoord8.xyz.xy * _SequinsNoise_ST.xy + _SequinsNoise_ST.zw;
				float2 temp_output_454_0 = ( uv_SequinsNoise * _SequinsFrequency );
				float mulTime450 = _TimeParameters.x * _SequinsSpakleSpeed;
				float smoothstepResult462 = smoothstep( _Threshold , ( _Threshold + _Range ) , ( tex2D( _SequinsNoise, ( ( (ase_screenPosNorm).xy * _SequinsScreenContribution ) + temp_output_454_0 + mulTime450 ) ).g * tex2D( _SequinsNoise, ( ( temp_output_454_0 * 1.1 ) + -mulTime450 ) ).g ));
				float2 uv_SequinsMask = IN.ase_texcoord8.xyz.xy * _SequinsMask_ST.xy + _SequinsMask_ST.zw;
				float4 Sequins440 = ( _SequinsColor * smoothstepResult462 * tex2D( _SequinsMask, uv_SequinsMask ).r );
				float4 lerpResult541 = lerp( temp_output_284_0 , ( temp_output_284_0 + Sequins440 ) , _SequinsStrength);
				
				float MaskMap_S526 = ( 0.0 * _Smoothness );
				
				float EyeShadowA492 = tex2DNode259.a;
				
				float3 Albedo = ( Reflective489 + lerpResult541 ).rgb;
				float3 Normal = Normal78;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = MaskMap_S526;
				float Occlusion = 1;
				float Alpha = saturate( ( EyeShadowA492 * _DiffuseVisibility ) );
				float AlphaClipThreshold = 0.5;
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

				return tex2D(_Diffuse_EyeShadow, IN.uv.xy);
			}

			ENDHLSL
		}
		
	}


	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	
}