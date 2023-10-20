Shader "TA/Optimize/Role/Cloth/5000004_501_01"
{
	Properties
	{
		_Diffuse("Diffuse", 2D) = "white" {}
		_DiffuseMultiple1("DiffuseMultiple", Float) = 1
		_DiffuseMultiple("DiffuseMultiple", Float) = 1
		_DiffuseMultiple2("DiffuseMultiple", Float) = 1
		_SMAO("SMAO", 2D) = "white" {}
		_Normal_01("Normal_01", 2D) = "bump" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0.2
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		_FresnelBiss("FresnelBiss", Range( -0.5 , 0.5)) = 0
		_FresnelScale("FresnelScale", Float) = 0.5
		_FresnelPower("FresnelPower", Float) = 2
		_FresnelColor("FresnelColor", Color) = (0.259434,1,0.9389895,0)
		_skybox_001("skybox_001", CUBE) = "white" {}
		_MetallicReflection("MetallicReflection", Float) = 1
		_MetallicReflectionColor("MetallicReflectionColor", Color) = (1,1,1,0)
		_Reflection("Reflection", Float) = 1
		_ReflectionColor("ReflectionColor", Color) = (1,1,1,0)
		_AO("AO", Range( 0 , 1)) = 1
		_Emission("Emission", 2D) = "white" {}
		_EmissionColor("EmissionColor", Color) = (1,1,1,0)
	}


	SubShader
	{
		LOD 500
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		
		Pass
		{
			Tags { "LightMode"="UniversalForward" }

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
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Diffuse_ST;
			float4 _EmissionColor;
			float4 _Emission_ST;
			float4 _ReflectionColor;
			float4 _MetallicReflectionColor;
			float4 _FresnelColor;
			float4 _SMAO_ST;
			float4 _Normal_01_ST;
			float _FresnelScale;
			float _MetallicReflection;
			float _Metallic;
			float _FresnelBiss;
			float _DiffuseMultiple2;
			float _Reflection;
			float _AO;
			float _DiffuseMultiple;
			float _DiffuseMultiple1;
			float _FresnelPower;
			float _Smoothness;
			CBUFFER_END
			sampler2D _Diffuse;
			sampler2D _SMAO;
			samplerCUBE _skybox_001;
			sampler2D _Normal_01;
			sampler2D _Emission;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

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

				float fresnelNdotV46 = dot( WorldNormal, WorldViewDirection );
				float fresnelNode46 = ( _FresnelBiss + _FresnelScale * pow(abs( 1.0 - fresnelNdotV46), _FresnelPower ) );
				float4 switchResult116 = (((ase_vface>0)?(( fresnelNode46 * _FresnelColor )):(float4( 0,0,0,0 ))));
				float2 uv_Diffuse = IN.ase_texcoord8.xyz.xy * _Diffuse_ST.xy + _Diffuse_ST.zw;
				float4 tex2DNode6 = tex2D( _Diffuse, uv_Diffuse );
				float4 cloth_D103 = tex2DNode6;
				float2 uv_SMAO = IN.ase_texcoord8.xyz.xy * _SMAO_ST.xy + _SMAO_ST.zw;
				float4 tex2DNode13 = tex2D( _SMAO, uv_SMAO );
				float Metallic93 = tex2DNode13.g;
				float2 uv_Normal_01 = IN.ase_texcoord8.xyz.xy * _Normal_01_ST.xy + _Normal_01_ST.zw;
				float3 Normal107 = UnpackNormalScale( tex2D( _Normal_01, uv_Normal_01 ), 1.0f );
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 worldRefl84 = reflect( -WorldViewDirection, float3( dot( tanToWorld0, Normal107 ), dot( tanToWorld1, Normal107 ), dot( tanToWorld2, Normal107 ) ) );
				float4 texCUBENode78 = texCUBE( _skybox_001, worldRefl84 );
				float AO94 = tex2DNode13.b;
				float4 temp_cast_0 = (AO94).xxxx;
				float4 blendOpSrc114 = temp_cast_0;
				float4 blendOpDest114 = cloth_D103;
				float4 lerpBlendMode114 = lerp(blendOpDest114,min( blendOpSrc114 , blendOpDest114 ),_AO);
				
				float2 uv_Emission = IN.ase_texcoord8.xyz.xy * _Emission_ST.xy + _Emission_ST.zw;
				
				float Smoothness92 = tex2DNode13.r;
				
				float cloth_A105 = tex2DNode6.a;
				
				float3 Albedo = ( ( switchResult116 + ( cloth_D103 * _MetallicReflection * Metallic93 * _MetallicReflectionColor * texCUBENode78 ) + ( ( texCUBENode78 * _ReflectionColor * Metallic93 ) * Metallic93 * _Reflection ) + ( saturate( lerpBlendMode114 )) ) * _DiffuseMultiple ).rgb;
				float3 Normal = Normal107;
				float3 Emission = ( tex2D( _Emission, uv_Emission ) * _EmissionColor ).rgb;
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
				
				clip(Alpha - AlphaClipThreshold);

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
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
				return color;
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
			Tags { "LightMode"="UniversalForward" }

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
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Diffuse_ST;
			float4 _Normal_01_ST;
			float _DiffuseMultiple1;
			CBUFFER_END
			sampler2D _Diffuse;
			sampler2D _Normal_01;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord8.xy = v.texcoord.xy;
				o.ase_texcoord8.zw = 0;

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
				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float2 uv_Diffuse = IN.ase_texcoord8.xy * _Diffuse_ST.xy + _Diffuse_ST.zw;
				float4 tex2DNode6 = tex2D( _Diffuse, uv_Diffuse );
				float4 cloth_D103 = tex2DNode6;
				
				float2 uv_Normal_01 = IN.ase_texcoord8.xy * _Normal_01_ST.xy + _Normal_01_ST.zw;
				float3 Normal107 = UnpackNormalScale( tex2D( _Normal_01, uv_Normal_01 ), 1.0f );
				
				float cloth_A105 = tex2DNode6.a;
				
				float3 Albedo = ( cloth_D103 * _DiffuseMultiple1 ).rgb;
				float3 Normal = Normal107;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = 0.2;
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

			sampler2D _Diffuse;

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

				half4 color = tex2D(_Diffuse, IN.uv.xy);
				clip(color.a - 0.5);
				return color;
			}

			ENDHLSL
		}
		
	}

	

	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	
}