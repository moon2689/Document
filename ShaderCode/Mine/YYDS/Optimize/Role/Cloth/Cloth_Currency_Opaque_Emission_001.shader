Shader "TA/Optimize/Role/Cloth/Currency_Opaque_Emission_001"
{
	Properties
	{
		_Diffuse_Front("Diffuse_Front", 2D) = "white" {}
		_DiffuseMultipleF("DiffuseMultipleF", Float) = 1
		_DiffuseMultipleB("DiffuseMultipleB", Float) = 1
		_Power("Power", Float) = 1
		_Normal_Front("Normal_Front", 2D) = "bump" {}
		_SMAO_Front("SMAO_Front", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		_AO("AO", Range( 0 , 1)) = 0.2
		_FresnelBiss("FresnelBiss", Range( -0.5 , 0.5)) = 0
		_FresnelScale("FresnelScale", Float) = 0
		_FresnelPower("FresnelPower", Float) = 0
		_FresnelColor("FresnelColor", Color) = (1,1,1,0)
		_skybox_001("skybox_001", CUBE) = "white" {}
		_MetallicReflection("MetallicReflection", Float) = 1
		_MetallicReflectionLOD300("MetallicReflectionLOD300", Float) = 1
		_MetallicReflectionColor("MetallicReflectionColor", Color) = (1,1,1,0)
		_Reflection("Reflection", Float) = 1
		_ReflectionColor("ReflectionColor", Color) = (1,1,1,0)
		_Emission("Emission", 2D) = "white" {}
		[HDR]_EmissionColor("EmissionColor", Color) = (1,1,1,0)
		_EmissionPower("EmissionPower", Range( 0 , 5)) = 0
	}


	SubShader
	{
		LOD 500
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="AlphaTest" }
		
		Pass
		{
			Tags { "LightMode"="UniversalForward" }
			Cull Off

			HLSLPROGRAM

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

			#define SHADERPASS SHADERPASS_FORWARD

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
			float4 _Diffuse_Front_ST;
			float4 _Normal_Front_ST;
			float4 _ReflectionColor;
			float4 _EmissionColor;
			float4 _Emission_ST;
			float4 _MetallicReflectionColor;
			float4 _SMAO_Front_ST;
			float4 _FresnelColor;
			float _EmissionPower;
			float _AO;
			float _MetallicReflection;
			float _FresnelPower;
			float _FresnelScale;
			float _FresnelBiss;
			float _Power;
			float _DiffuseMultipleB;
			float _Reflection;
			float _MetallicReflectionLOD300;
			float _DiffuseMultipleF;
			float _Metallic;
			float _Smoothness;
			CBUFFER_END
			sampler2D _Diffuse_Front;
			sampler2D _SMAO_Front;
			samplerCUBE _skybox_001;
			sampler2D _Normal_Front;
			sampler2D _Emission;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord8.xyz = v.texcoord.xyz;
				o.ase_texcoord8.w = 0;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );
				o.fogFactorAndVertexLight = half4(0, vertexLight);
				
				o.clipPos = positionCS;
				return o;
			}
			
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			
			half4 frag ( VertexOutput IN, bool ase_vface : SV_IsFrontFace ) : SV_Target
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

				float DiffuseMultipleF245 = _DiffuseMultipleF;
				float fresnelNdotV46 = dot( WorldNormal, WorldViewDirection );
				float fresnelNode46 = ( _FresnelBiss + _FresnelScale * pow( max( 1.0 - fresnelNdotV46 , 0.0001 ), _FresnelPower ) );
				float4 switchResult169 = (((ase_vface>0)?(( fresnelNode46 * _FresnelColor )):(float4( 0,0,0,0 ))));
				float2 uv_Diffuse_Front = IN.ase_texcoord8.xyz.xy * _Diffuse_Front_ST.xy + _Diffuse_Front_ST.zw;
				float4 tex2DNode6 = tex2D( _Diffuse_Front, uv_Diffuse_Front );
				float4 cloth_D103 = tex2DNode6;
				float2 uv_SMAO_Front = IN.ase_texcoord8.xyz.xy * _SMAO_Front_ST.xy + _SMAO_Front_ST.zw;
				float4 tex2DNode13 = tex2D( _SMAO_Front, uv_SMAO_Front );
				float Metallic93 = tex2DNode13.g;
				float2 uv_Normal_Front = IN.ase_texcoord8.xyz.xy * _Normal_Front_ST.xy + _Normal_Front_ST.zw;
				float3 Normal116 = UnpackNormalScale( tex2D( _Normal_Front, uv_Normal_Front ), 1.0f );
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 worldRefl84 = reflect( -WorldViewDirection, float3( dot( tanToWorld0, Normal116 ), dot( tanToWorld1, Normal116 ), dot( tanToWorld2, Normal116 ) ) );
				float4 texCUBENode78 = texCUBE( _skybox_001, worldRefl84 );
				float4 ReflectionColor259 = _ReflectionColor;
				float Smoothness92 = tex2DNode13.r;
				float Reflection251 = _Reflection;
				float AO94 = tex2DNode13.b;
				float4 lerpResult119 = lerp( cloth_D103 , ( cloth_D103 * AO94 ) , _AO);
				float4 temp_output_53_0 = ( switchResult169 + ( cloth_D103 * ( _MetallicReflection * Metallic93 * _MetallicReflectionColor * texCUBENode78 ) ) + ( ( texCUBENode78 * ReflectionColor259 ) * ( 1.0 - Smoothness92 ) * Reflection251 ) + lerpResult119 );
				float DiffuseMultipleB249 = _DiffuseMultipleB;
				float4 switchResult179 = (((ase_vface>0)?(( DiffuseMultipleF245 * temp_output_53_0 )):(( temp_output_53_0 * DiffuseMultipleB249 ))));
				float Power247 = _Power;
				float4 temp_cast_0 = (Power247).xxxx;
				
				float2 uv_Emission = IN.ase_texcoord8.xyz.xy * _Emission_ST.xy + _Emission_ST.zw;
				
				float cloth_A105 = tex2DNode6.a;
				
				float3 Albedo = pow( abs(switchResult179) , temp_cast_0 ).rgb;
				float3 Normal = Normal116;
				float3 Emission = ( tex2D( _Emission, uv_Emission ) * _EmissionPower * _EmissionColor ).rgb;
				float3 Specular = 0.5;
				float Metallic = ( Metallic93 * _Metallic );
				float Smoothness = ( ( 1.0 - Smoothness92 ) * _Smoothness );
				float Occlusion = 1;
				float Alpha = cloth_A105;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;


				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
				inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, IN.lightmapUVOrVertexSH.xyz, inputData.normalWS );
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

				clip(Alpha - 0.5);
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
			TEXTURE2D(_Diffuse_Front); SAMPLER(sampler_Diffuse_Front);

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
				half alpha = SAMPLE_TEXTURE2D(_Diffuse_Front, sampler_Diffuse_Front, input.uv).a;
				clip(alpha - 0.5);
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

		Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }
		Cull Off

		Pass
		{
			Tags { "LightMode" = "UniversalForward" }

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
			float4 _Normal_Front_ST;
			float4 _ReflectionColor;
			float _DiffuseMultipleF;
			float _MetallicReflectionLOD300;
			float _Reflection;
			float _DiffuseMultipleB;
			float _Power;
			CBUFFER_END
			sampler2D _Diffuse_Front;
			samplerCUBE _skybox_001;
			sampler2D _Normal_Front;



			VertexOutput VertexFunction(VertexInput v)
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord8.xyz = v.texcoord.xyz;
				o.ase_texcoord8.w = 0;

				float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
				float3 positionVS = TransformWorldToView(positionWS);
				float4 positionCS = TransformWorldToHClip(positionWS);

				VertexNormalInputs normalInput = GetVertexNormalInputs(v.ase_normal, v.ase_tangent);

				o.tSpace0 = float4(normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);

				OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);

				half3 vertexLight = VertexLighting(positionWS, normalInput.normalWS);
				o.fogFactorAndVertexLight = half4(0, vertexLight);

				o.clipPos = positionCS;
				return o;
			}

			VertexOutput vert(VertexInput v)
			{
				return VertexFunction(v);
			}


			half4 frag(VertexOutput IN, bool ase_vface : SV_IsFrontFace) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition(IN.clipPos.xyz, unity_LODFade.x);
				#endif

				float3 WorldNormal = normalize(IN.tSpace0.xyz);
				float3 WorldTangent = IN.tSpace1.xyz;
				float3 WorldBiTangent = IN.tSpace2.xyz;
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz - WorldPosition;
				WorldViewDirection = SafeNormalize(WorldViewDirection);

				float DiffuseMultipleF245 = _DiffuseMultipleF;
				float2 uv_Diffuse_Front = IN.ase_texcoord8.xyz.xy * _Diffuse_Front_ST.xy + _Diffuse_Front_ST.zw;
				float4 tex2DNode6 = tex2D(_Diffuse_Front, uv_Diffuse_Front);
				float4 cloth_D103 = tex2DNode6;
				float2 uv_Normal_Front = IN.ase_texcoord8.xyz.xy * _Normal_Front_ST.xy + _Normal_Front_ST.zw;
				float3 Normal116 = UnpackNormalScale(tex2D(_Normal_Front, uv_Normal_Front), 1.0f);
				float3 tanToWorld0 = float3(WorldTangent.x, WorldBiTangent.x, WorldNormal.x);
				float3 tanToWorld1 = float3(WorldTangent.y, WorldBiTangent.y, WorldNormal.y);
				float3 tanToWorld2 = float3(WorldTangent.z, WorldBiTangent.z, WorldNormal.z);
				float3 worldRefl209 = reflect(-WorldViewDirection, float3(dot(tanToWorld0, Normal116), dot(tanToWorld1, Normal116), dot(tanToWorld2, Normal116)));
				float4 texCUBENode210 = texCUBE(_skybox_001, worldRefl209);
				float Reflection251 = _Reflection;
				float4 ReflectionColor259 = _ReflectionColor;
				float4 temp_output_230_0 = ((cloth_D103 * (_MetallicReflectionLOD300 * texCUBENode210)) + (texCUBENode210 * cloth_D103 * Reflection251 * ReflectionColor259));
				float DiffuseMultipleB249 = _DiffuseMultipleB;
				float4 switchResult234 = (((ase_vface > 0) ? ((DiffuseMultipleF245 * temp_output_230_0)) : ((temp_output_230_0 * DiffuseMultipleB249))));
				float Power247 = _Power;
				float4 temp_cast_0 = (Power247).xxxx;

				float cloth_A105 = tex2DNode6.a;

				float3 Albedo = pow(abs(switchResult234) , temp_cast_0).rgb;
				float3 Normal = Normal116;
				float Metallic = 0;
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
				inputData.normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));

				SurfaceData surfaceData;
				surfaceData.albedo = Albedo;
				surfaceData.metallic = saturate(Metallic);
				surfaceData.specular = 0.5;
				surfaceData.smoothness = 0.3,
				surfaceData.occlusion = Occlusion,
				surfaceData.emission = 0,
				surfaceData.alpha = saturate(Alpha);
				surfaceData.normalTS = Normal;
				surfaceData.clearCoatMask = 0;
				surfaceData.clearCoatSmoothness = 1;

				half4 color = Lighting_BlinnPhong(inputData, surfaceData);
				return color;
			}

			ENDHLSL
		}

	}


	SubShader
	{
		LOD 100

		Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "AlphaTest" }
		Cull Off

		Pass
		{
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

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.clipPos = TransformObjectToHClip(v.vertex.xyz);
				o.uv = v.texcoord;
				return o;
			}

			half4 frag(VertexOutput IN) : SV_Target
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