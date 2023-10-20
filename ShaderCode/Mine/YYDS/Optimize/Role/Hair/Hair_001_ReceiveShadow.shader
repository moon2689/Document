Shader "TA/Optimize/Role/Hair/Hair_001_ReceiveShadow"
{
	Properties
	{
		_Diffuse("Diffuse", 2D) = "white" {}
		_DiffuseColor("DiffuseColor", Color) = (1,1,1,0)
		_DiffuseMultiple("DiffuseMultiple", Float) = 1
		_R1SpecalurColor("R1-SpecalurColor", Color) = (0.990566,0.4440468,0,0)
		[HDR]_R2SpecalurColor("R2-SpecalurColor", Color) = (0,0.5004212,0.8867924,0)
		_AnisotropyRang1("Anisotropy-Rang1", Range( 1 , 2000)) = 155
		_AnisotropyRang2("Anisotropy-Rang2", Range( 1 , 2000)) = 391
		_MaskMap("MaskMap", 2D) = "white" {}
		_HighlightsDetails("HighlightsDetails", Range( 0.1 , 5)) = 2.89
		_Normal("Normal", 2D) = "bump" {}
		_NormalStrength("NormalStrength", Range( 0 , 1)) = 1
		_AnisotropyBias("Anisotropy-Bias", Range( -1 , 1)) = 0.158
		_HLFrePower("HL-Fre-Power", Range( 0 , 5)) = 1.33
		_Metallic("Metallic", Range( 0 , 3)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[Toggle]_MaskBBreakAO("MaskB-Break-AO", Float) = 0
		[HDR]_GradientColor0("GradientColor 0", Color) = (0,0,0,1)
		_TerminalGradient("TerminalGradient", Range( 0 , 4)) = 0
		_Gradient("Gradient", Range( -3 , 1)) = 1
		_Float2("Float 2", Float) = 0.688
		_ShadowColor("ShadowColor", Color) = (0,0,0,0)
		_ShadowColorRange("ShadowColorRange", Range( 0 , 1)) = 0.3417478
		_ShadowColorStrength("ShadowColorStrength", Float) = 1
	}

	SubShader
	{
		LOD 0
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		Cull Back
		ZWrite Off
		ZTest LEqual
		Offset 0,0
		AlphaToMask Off
		
		Pass
		{
			Name "ExtraPrePass"
			
			
			Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
			Cull Back
			ZWrite On
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_SHADOW_ON 1
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120107

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"


			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _GradientColor0;
			float4 _Normal_ST;
			float4 _ShadowColor;
			float4 _R2SpecalurColor;
			float4 _R1SpecalurColor;
			float4 _MaskMap_ST;
			float4 _Diffuse_ST;
			float4 _DiffuseColor;
			float _AnisotropyBias;
			float _NormalStrength;
			float _DiffuseMultiple;
			float _ShadowColorStrength;
			float _ShadowColorRange;
			float _HighlightsDetails;
			float _Float2;
			float _MaskBBreakAO;
			float _Metallic;
			float _Gradient;
			float _AnisotropyRang2;
			float _TerminalGradient;
			float _AnisotropyRang1;
			float _HLFrePower;
			float _Smoothness;
			CBUFFER_END
			sampler2D _Diffuse;
			sampler2D _MaskMap;


			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				o.ase_texcoord5.xyz = ase_worldNormal;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float2 uv_Diffuse = IN.ase_texcoord3.xy * _Diffuse_ST.xy + _Diffuse_ST.zw;
				float4 tex2DNode242 = tex2D( _Diffuse, uv_Diffuse );
				float2 texCoord314 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_332_0 = ( _Gradient + ( texCoord314.y * _TerminalGradient ) );
				float ifLocalVar331 = 0;
				if( 1.0 <= temp_output_332_0 )
				ifLocalVar331 = 1.0;
				else
				ifLocalVar331 = temp_output_332_0;
				float4 lerpResult328 = lerp( ( _GradientColor0 * tex2DNode242 ) , ( tex2DNode242 * _DiffuseColor ) , ifLocalVar331);
				float3 ase_worldBitangent = IN.ase_texcoord4.xyz;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 normalizedWorldNormal = normalize( ase_worldNormal );
				float2 texCoord294 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float4 appendResult296 = (float4(_HighlightsDetails , 1.0 , 0.0 , 0.0));
				float4 tex2DNode65 = tex2D( _MaskMap, ( float4( texCoord294, 0.0 , 0.0 ) * appendResult296 ).xy );
				float clampResult270 = clamp( ( tex2DNode65.r + ( ( tex2DNode65.g * _AnisotropyBias ) + -0.2 ) ) , -0.1 , 1.333 );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float dotResult156 = dot( ( ase_worldBitangent + ( normalizedWorldNormal * clampResult270 ) ) , ase_worldViewDir );
				float temp_output_186_0 = sqrt( sqrt( ( 1.0 - ( dotResult156 * dotResult156 ) ) ) );
				float2 uv_MaskMap = IN.ase_texcoord3.xy * _MaskMap_ST.xy + _MaskMap_ST.zw;
				float4 tex2DNode176 = tex2D( _MaskMap, uv_MaskMap );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult117 = dot( ase_worldViewDir , ase_worldNormal );
				float4 clampResult292 = clamp( ( ( ( pow( temp_output_186_0 , _AnisotropyRang1 ) * _R1SpecalurColor ) + ( pow( temp_output_186_0 , _AnisotropyRang2 ) * _R2SpecalurColor * tex2DNode176.r ) ) * float4( 1,1,1,0 ) * (( _MaskBBreakAO )?( 1.0 ):( tex2DNode176.r )) * pow( saturate( dotResult117 ) , _HLFrePower ) ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
				float4 Color362 = ( lerpResult328 + clampResult292 );
				
				float DiffuseA359 = tex2DNode242.a;
				
				float3 Color = ( (-0.015 + (_MainLightColor.a - 0.0) * (0.25 - -0.015) / (1.0 - 0.0)) * Color362 ).rgb;
				float Alpha = DiffuseA359;
				float AlphaClipThreshold = _Float2;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha

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
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _GradientColor0;
			float4 _Normal_ST;
			float4 _ShadowColor;
			float4 _R2SpecalurColor;
			float4 _R1SpecalurColor;
			float4 _MaskMap_ST;
			float4 _Diffuse_ST;
			float4 _DiffuseColor;
			float _AnisotropyBias;
			float _NormalStrength;
			float _DiffuseMultiple;
			float _ShadowColorStrength;
			float _ShadowColorRange;
			float _HighlightsDetails;
			float _Float2;
			float _MaskBBreakAO;
			float _Metallic;
			float _Gradient;
			float _AnisotropyRang2;
			float _TerminalGradient;
			float _AnisotropyRang1;
			float _HLFrePower;
			float _Smoothness;
			CBUFFER_END
			sampler2D _Diffuse;
			sampler2D _MaskMap;
			sampler2D _Normal;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord8.xy = v.texcoord.xy;
				o.ase_texcoord8.zw = 0;
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

			half4 frag ( VertexOutput IN ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				
				float3 WorldNormal = normalize( IN.tSpace0.xyz );
				float3 WorldTangent = IN.tSpace1.xyz;
				float3 WorldBiTangent = IN.tSpace2.xyz;
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
	
				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float4 ShadowCoords = TransformWorldToShadowCoord(WorldPosition);

				float2 uv_Diffuse = IN.ase_texcoord8.xy * _Diffuse_ST.xy + _Diffuse_ST.zw;
				float4 tex2DNode242 = tex2D( _Diffuse, uv_Diffuse );
				float2 texCoord314 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_332_0 = ( _Gradient + ( texCoord314.y * _TerminalGradient ) );
				float ifLocalVar331 = 0;
				if( 1.0 <= temp_output_332_0 )
				ifLocalVar331 = 1.0;
				else
				ifLocalVar331 = temp_output_332_0;
				float4 lerpResult328 = lerp( ( _GradientColor0 * tex2DNode242 ) , ( tex2DNode242 * _DiffuseColor ) , ifLocalVar331);
				float3 normalizedWorldNormal = normalize( WorldNormal );
				float2 texCoord294 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 appendResult296 = (float4(_HighlightsDetails , 1.0 , 0.0 , 0.0));
				float4 tex2DNode65 = tex2D( _MaskMap, ( float4( texCoord294, 0.0 , 0.0 ) * appendResult296 ).xy );
				float clampResult270 = clamp( ( tex2DNode65.r + ( ( tex2DNode65.g * _AnisotropyBias ) + -0.2 ) ) , -0.1 , 1.333 );
				float dotResult156 = dot( ( WorldBiTangent + ( normalizedWorldNormal * clampResult270 ) ) , WorldViewDirection );
				float temp_output_186_0 = sqrt( sqrt( ( 1.0 - ( dotResult156 * dotResult156 ) ) ) );
				float2 uv_MaskMap = IN.ase_texcoord8.xy * _MaskMap_ST.xy + _MaskMap_ST.zw;
				float4 tex2DNode176 = tex2D( _MaskMap, uv_MaskMap );
				float dotResult117 = dot( WorldViewDirection , WorldNormal );
				float4 clampResult292 = clamp( ( ( ( pow( temp_output_186_0 , _AnisotropyRang1 ) * _R1SpecalurColor ) + ( pow( temp_output_186_0 , _AnisotropyRang2 ) * _R2SpecalurColor * tex2DNode176.r ) ) * float4( 1,1,1,0 ) * (( _MaskBBreakAO )?( 1.0 ):( tex2DNode176.r )) * pow( saturate( dotResult117 ) , _HLFrePower ) ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
				float4 Color362 = ( lerpResult328 + clampResult292 );
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float dotResult352 = dot( ( _MainLightPosition.xyz * ase_lightAtten ) , WorldNormal );
				float temp_output_355_0 = ( 1.0 - (dotResult352*0.71 + _ShadowColorRange) );
				float4 lerpResult375 = lerp( Color362 , saturate( ( temp_output_355_0 * _ShadowColor * _ShadowColorStrength ) ) , temp_output_355_0);
				
				float2 uv_Normal = IN.ase_texcoord8.xy * _Normal_ST.xy + _Normal_ST.zw;
				float3 unpack136 = UnpackNormalScale( tex2D( _Normal, uv_Normal ), _NormalStrength );
				unpack136.z = lerp( 1, unpack136.z, saturate(_NormalStrength) );
				
				float DiffuseA359 = tex2DNode242.a;
				
				float3 Albedo = ( lerpResult375 * _DiffuseMultiple ).rgb;
				float3 Normal = unpack136;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = _Metallic;
				float Smoothness = _Smoothness;
				float Occlusion = 1;
				float Alpha = DiffuseA359;
				float AlphaClipThreshold = 0.0;
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
				inputData.shadowCoord = ShadowCoords;
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
	
	CustomEditor "UnityEditor.ShaderGraphLitGUI"
	Fallback "Hidden/InternalErrorShader"
	
}