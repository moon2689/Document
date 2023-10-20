Shader "TA/Optimize/Role/Role/Girl_Eyes_001"
{
	Properties
	{
		_PupilDiffuse("PupilDiffuse", 2D) = "white" {}
		[HDR]_PupilColor("PupilColor", Color) = (0.9528302,0.7955233,0.9465379,0)
		_PupilColorStrength("PupilColorStrength", Float) = 1
		_EyeballDiffuse("EyeballDiffuse", 2D) = "white" {}
		_EyeballColor("EyeballColor", Color) = (0.9058824,0.909804,0.8705883,1)
		_PupilZoom("PupilZoom", Range( 0.9 , 3)) = 0.9
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_BackDepthScale("Back Depth Scale", Range( -1 , 1)) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Eye_S("Eye_S", 2D) = "white" {}
		_Highlights("Highlights", 2D) = "white" {}
		_HighlightPosition_1("HighlightPosition_1", Range( 0.6 , 2)) = 0.15
		_HighlightIntensity_1("HighlightIntensity_1", Range( 0 , 2)) = 1
		_HighlightAngle_1("HighlightAngle_1", Float) = 0
		_HighlightRotationSpeed_1("HighlightRotationSpeed_1", Float) = 0.3
		_HighlightPosition_2("HighlightPosition_2", Range( 0.6 , 2)) = 0.15
		_HighlightIntensity_2("HighlightIntensity_2", Range( 0 , 2)) = 1
		_HighlightAngle_2("HighlightAngle_2", Float) = 0
		_HighlightRotationSpeed_2("HighlightRotationSpeed_2", Float) = -0.2
		_HighlightPosition_3("HighlightPosition_3", Range( 0.6 , 2)) = 0.15
		_HighlightIntensity_3("HighlightIntensity_3", Range( 0 , 2)) = 1
		_HighlightAngle_3("HighlightAngle_3", Float) = 0
		_HighlightRotationSpeed_3("HighlightRotationSpeed_3", Float) = 2.45
		_Skybox_003("Skybox_003", 2D) = "white" {}
		_Vector1("Vector 1", Vector) = (0.5,0.5,0,0)
		_EyeMask_001("EyeMask_001", 2D) = "white" {}
		_PupilRefraction("PupilRefraction", Float) = 0.2
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

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
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
			float4 _EyeballColor;
			float4 _PupilColor;
			float2 _Vector1;
			float _BackDepthScale;
			float _HighlightIntensity_3;
			float _HighlightRotationSpeed_3;
			float _HighlightAngle_3;
			float _HighlightPosition_3;
			float _HighlightIntensity_2;
			float _HighlightRotationSpeed_2;
			float _HighlightAngle_2;
			float _HighlightIntensity_1;
			float _PupilColorStrength;
			float _HighlightRotationSpeed_1;
			float _HighlightAngle_1;
			float _HighlightPosition_1;
			float _PupilRefraction;
			float _PupilZoom;
			float _HighlightPosition_2;
			float _Metallic;
			CBUFFER_END
			sampler2D _Skybox_003;
			sampler2D _PupilDiffuse;
			sampler2D _Eye_S;
			sampler2D _EyeMask_001;
			sampler2D _EyeballDiffuse;
			sampler2D _Highlights;
			UNITY_INSTANCING_BUFFER_START(EMDRoleGirl_Eyes_001)
				UNITY_DEFINE_INSTANCED_PROP(float4, _Skybox_003_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _Eye_S_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _EyeMask_001_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _EyeballDiffuse_ST)
				UNITY_DEFINE_INSTANCED_PROP(float, _Smoothness)
			UNITY_INSTANCING_BUFFER_END(EMDRoleGirl_Eyes_001)


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

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

				float4 _Skybox_003_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(EMDRoleGirl_Eyes_001,_Skybox_003_ST);
				float2 uv_Skybox_003 = IN.ase_texcoord8.xy * _Skybox_003_ST_Instance.xy + _Skybox_003_ST_Instance.zw;
				float2 Offset167 = ( ( 0.0 - 1 ) * ( WorldViewDirection.xy / WorldViewDirection.z ) * 0.5 ) + uv_Skybox_003;
				float2 Offset256 = ( ( 0.0 - 1 ) * WorldViewDirection.xy * _BackDepthScale ) + Offset167;
				float2 texCoord239 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float PupilZoom315 = _PupilZoom;
				float4 _Eye_S_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(EMDRoleGirl_Eyes_001,_Eye_S_ST);
				float2 uv_Eye_S = IN.ase_texcoord8.xy * _Eye_S_ST_Instance.xy + _Eye_S_ST_Instance.zw;
				float2 lerpResult245 = lerp( texCoord239 , ( ( (float2( -0.7,-0.7 ) + (texCoord239 - float2( 0,0 )) * (float2( 0.7,0.7 ) - float2( -0.7,-0.7 )) / (float2( 1,1 ) - float2( 0,0 ))) * PupilZoom315 ) + _Vector1 ) , tex2D( _Eye_S, uv_Eye_S ).r);
				float4 _EyeMask_001_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(EMDRoleGirl_Eyes_001,_EyeMask_001_ST);
				float2 uv_EyeMask_001 = IN.ase_texcoord8.xy * _EyeMask_001_ST_Instance.xy + _EyeMask_001_ST_Instance.zw;
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 ase_tanViewDir =  tanToWorld0 * WorldViewDirection.x + tanToWorld1 * WorldViewDirection.y  + tanToWorld2 * WorldViewDirection.z;
				ase_tanViewDir = normalize(ase_tanViewDir);
				float2 Offset263 = ( ( 0.0 - 1 ) * ase_tanViewDir.xy * ( _PupilRefraction * tex2D( _EyeMask_001, uv_EyeMask_001 ).a ) ) + lerpResult245;
				float4 tex2DNode121 = tex2D( _PupilDiffuse, Offset263 );
				float Diffuse_A277 = tex2DNode121.a;
				float4 lerpResult271 = lerp( tex2D( _Skybox_003, Offset256 ) , tex2D( _Skybox_003, Offset167 ) , ( 1.0 - Diffuse_A277 ));
				float4 _EyeballDiffuse_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(EMDRoleGirl_Eyes_001,_EyeballDiffuse_ST);
				float2 uv_EyeballDiffuse = IN.ase_texcoord8.xy * _EyeballDiffuse_ST_Instance.xy + _EyeballDiffuse_ST_Instance.zw;
				float4 temp_output_306_0 = ( _EyeballColor * tex2D( _EyeballDiffuse, uv_EyeballDiffuse ) );
				float4 lerpResult252 = lerp( temp_output_306_0 , ( tex2DNode121 * _PupilColor ) , tex2DNode121.a);
				float4 lerpResult264 = lerp( lerpResult252 , temp_output_306_0 , ( 1.0 - Diffuse_A277 ));
				float2 texCoord180 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_226_0 = (float2( -0.5,-0.5 ) + (texCoord180 - float2( 0,0 )) * (float2( 0.5,0.5 ) - float2( -0.5,-0.5 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 _Vector0 = float2(0.5,0.5);
				float cos334 = cos( _HighlightAngle_1 );
				float sin334 = sin( _HighlightAngle_1 );
				float2 rotator334 = mul( ( ( temp_output_226_0 * PupilZoom315 * _HighlightPosition_1 ) + _Vector0 ) - float2( 0.5,0.5 ) , float2x2( cos334 , -sin334 , sin334 , cos334 )) + float2( 0.5,0.5 );
				float3 temp_output_191_0 = ( WorldViewDirection * _HighlightRotationSpeed_1 );
				float cos178 = cos( temp_output_191_0.x );
				float sin178 = sin( temp_output_191_0.x );
				float2 rotator178 = mul( rotator334 - float2( 0.5,0.5 ) , float2x2( cos178 , -sin178 , sin178 , cos178 )) + float2( 0.5,0.5 );
				float2 Offset177 = ( ( 0.0 - 1 ) * temp_output_191_0.xy * 0.0 ) + rotator178;
				float cos335 = cos( _HighlightAngle_2 );
				float sin335 = sin( _HighlightAngle_2 );
				float2 rotator335 = mul( ( _Vector0 + ( temp_output_226_0 * PupilZoom315 * _HighlightPosition_2 ) ) - float2( 0.5,0.5 ) , float2x2( cos335 , -sin335 , sin335 , cos335 )) + float2( 0.5,0.5 );
				float3 temp_output_199_0 = ( WorldViewDirection * _HighlightRotationSpeed_2 );
				float cos197 = cos( temp_output_199_0.x );
				float sin197 = sin( temp_output_199_0.x );
				float2 rotator197 = mul( rotator335 - float2( 0.5,0.5 ) , float2x2( cos197 , -sin197 , sin197 , cos197 )) + float2( 0.5,0.5 );
				float2 Offset198 = ( ( 0.0 - 1 ) * temp_output_199_0.xy * 0.0 ) + rotator197;
				float cos337 = cos( _HighlightAngle_3 );
				float sin337 = sin( _HighlightAngle_3 );
				float2 rotator337 = mul( ( _Vector0 + ( temp_output_226_0 * PupilZoom315 * _HighlightPosition_3 ) ) - float2( 0.5,0.5 ) , float2x2( cos337 , -sin337 , sin337 , cos337 )) + float2( 0.5,0.5 );
				float3 temp_output_203_0 = ( WorldViewDirection * _HighlightRotationSpeed_3 );
				float cos201 = cos( temp_output_203_0.x );
				float sin201 = sin( temp_output_203_0.x );
				float2 rotator201 = mul( rotator337 - float2( 0.5,0.5 ) , float2x2( cos201 , -sin201 , sin201 , cos201 )) + float2( 0.5,0.5 );
				float2 Offset202 = ( ( 0.0 - 1 ) * temp_output_203_0.xy * 0.0 ) + rotator201;
				
				float _Smoothness_Instance = UNITY_ACCESS_INSTANCED_PROP(EMDRoleGirl_Eyes_001,_Smoothness);
				
				float3 Albedo = ( ( ( lerpResult271 * 0.02 ) + lerpResult264 + ( ( tex2D( _Highlights, Offset177 ).r * _HighlightIntensity_1 ) + ( tex2D( _Highlights, Offset198 ).g * _HighlightIntensity_2 ) + ( tex2D( _Highlights, Offset202 ).b * _HighlightIntensity_3 ) ) ) * _PupilColorStrength ).rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = _Metallic;
				float Smoothness = _Smoothness_Instance;
				float Occlusion = 1;
				float Alpha = 1;
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
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		
		Pass
		{
			Tags { "LightMode"="UniversalForward" }

			HLSLPROGRAM
			#pragma multi_compile _ LOD_FADE_CROSSFADE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
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
			float4 _EyeballColor;
			float4 _PupilColor;
			float2 _Vector1;
			float _BackDepthScale;
			float _HighlightIntensity_3;
			float _HighlightRotationSpeed_3;
			float _HighlightAngle_3;
			float _HighlightPosition_3;
			float _HighlightIntensity_2;
			float _HighlightRotationSpeed_2;
			float _HighlightAngle_2;
			float _HighlightIntensity_1;
			float _PupilColorStrength;
			float _HighlightRotationSpeed_1;
			float _HighlightAngle_1;
			float _HighlightPosition_1;
			float _PupilRefraction;
			float _PupilZoom;
			float _HighlightPosition_2;
			float _Metallic;
			CBUFFER_END
			sampler2D _Skybox_003;
			sampler2D _PupilDiffuse;
			sampler2D _Eye_S;
			sampler2D _EyeMask_001;
			sampler2D _EyeballDiffuse;
			sampler2D _Highlights;
			UNITY_INSTANCING_BUFFER_START(EMDRoleGirl_Eyes_001)
				UNITY_DEFINE_INSTANCED_PROP(float4, _Skybox_003_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _Eye_S_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _EyeMask_001_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _EyeballDiffuse_ST)
				UNITY_DEFINE_INSTANCED_PROP(float, _Smoothness)
			UNITY_INSTANCING_BUFFER_END(EMDRoleGirl_Eyes_001)


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

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

				float4 _Skybox_003_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(EMDRoleGirl_Eyes_001,_Skybox_003_ST);
				float2 uv_Skybox_003 = IN.ase_texcoord8.xy * _Skybox_003_ST_Instance.xy + _Skybox_003_ST_Instance.zw;
				float2 Offset167 = ( ( 0.0 - 1 ) * ( WorldViewDirection.xy / WorldViewDirection.z ) * 0.5 ) + uv_Skybox_003;
				float2 Offset256 = ( ( 0.0 - 1 ) * WorldViewDirection.xy * _BackDepthScale ) + Offset167;
				float2 texCoord239 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float PupilZoom315 = _PupilZoom;
				float4 _Eye_S_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(EMDRoleGirl_Eyes_001,_Eye_S_ST);
				float2 uv_Eye_S = IN.ase_texcoord8.xy * _Eye_S_ST_Instance.xy + _Eye_S_ST_Instance.zw;
				float2 lerpResult245 = lerp( texCoord239 , ( ( (float2( -0.7,-0.7 ) + (texCoord239 - float2( 0,0 )) * (float2( 0.7,0.7 ) - float2( -0.7,-0.7 )) / (float2( 1,1 ) - float2( 0,0 ))) * PupilZoom315 ) + _Vector1 ) , tex2D( _Eye_S, uv_Eye_S ).r);
				float4 _EyeMask_001_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(EMDRoleGirl_Eyes_001,_EyeMask_001_ST);
				float2 uv_EyeMask_001 = IN.ase_texcoord8.xy * _EyeMask_001_ST_Instance.xy + _EyeMask_001_ST_Instance.zw;
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 ase_tanViewDir =  tanToWorld0 * WorldViewDirection.x + tanToWorld1 * WorldViewDirection.y  + tanToWorld2 * WorldViewDirection.z;
				ase_tanViewDir = normalize(ase_tanViewDir);
				float2 Offset263 = ( ( 0.0 - 1 ) * ase_tanViewDir.xy * ( _PupilRefraction * tex2D( _EyeMask_001, uv_EyeMask_001 ).a ) ) + lerpResult245;
				float4 tex2DNode121 = tex2D( _PupilDiffuse, Offset263 );
				float Diffuse_A277 = tex2DNode121.a;
				float4 lerpResult271 = lerp( tex2D( _Skybox_003, Offset256 ) , tex2D( _Skybox_003, Offset167 ) , ( 1.0 - Diffuse_A277 ));
				float4 _EyeballDiffuse_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(EMDRoleGirl_Eyes_001,_EyeballDiffuse_ST);
				float2 uv_EyeballDiffuse = IN.ase_texcoord8.xy * _EyeballDiffuse_ST_Instance.xy + _EyeballDiffuse_ST_Instance.zw;
				float4 temp_output_306_0 = ( _EyeballColor * tex2D( _EyeballDiffuse, uv_EyeballDiffuse ) );
				float4 lerpResult252 = lerp( temp_output_306_0 , ( tex2DNode121 * _PupilColor ) , tex2DNode121.a);
				float4 lerpResult264 = lerp( lerpResult252 , temp_output_306_0 , ( 1.0 - Diffuse_A277 ));
				float2 texCoord180 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_226_0 = (float2( -0.5,-0.5 ) + (texCoord180 - float2( 0,0 )) * (float2( 0.5,0.5 ) - float2( -0.5,-0.5 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 _Vector0 = float2(0.5,0.5);
				float cos334 = cos( _HighlightAngle_1 );
				float sin334 = sin( _HighlightAngle_1 );
				float2 rotator334 = mul( ( ( temp_output_226_0 * PupilZoom315 * _HighlightPosition_1 ) + _Vector0 ) - float2( 0.5,0.5 ) , float2x2( cos334 , -sin334 , sin334 , cos334 )) + float2( 0.5,0.5 );
				float3 temp_output_191_0 = ( WorldViewDirection * _HighlightRotationSpeed_1 );
				float cos178 = cos( temp_output_191_0.x );
				float sin178 = sin( temp_output_191_0.x );
				float2 rotator178 = mul( rotator334 - float2( 0.5,0.5 ) , float2x2( cos178 , -sin178 , sin178 , cos178 )) + float2( 0.5,0.5 );
				float2 Offset177 = ( ( 0.0 - 1 ) * temp_output_191_0.xy * 0.0 ) + rotator178;
				float cos335 = cos( _HighlightAngle_2 );
				float sin335 = sin( _HighlightAngle_2 );
				float2 rotator335 = mul( ( _Vector0 + ( temp_output_226_0 * PupilZoom315 * _HighlightPosition_2 ) ) - float2( 0.5,0.5 ) , float2x2( cos335 , -sin335 , sin335 , cos335 )) + float2( 0.5,0.5 );
				float3 temp_output_199_0 = ( WorldViewDirection * _HighlightRotationSpeed_2 );
				float cos197 = cos( temp_output_199_0.x );
				float sin197 = sin( temp_output_199_0.x );
				float2 rotator197 = mul( rotator335 - float2( 0.5,0.5 ) , float2x2( cos197 , -sin197 , sin197 , cos197 )) + float2( 0.5,0.5 );
				float2 Offset198 = ( ( 0.0 - 1 ) * temp_output_199_0.xy * 0.0 ) + rotator197;
				float cos337 = cos( _HighlightAngle_3 );
				float sin337 = sin( _HighlightAngle_3 );
				float2 rotator337 = mul( ( _Vector0 + ( temp_output_226_0 * PupilZoom315 * _HighlightPosition_3 ) ) - float2( 0.5,0.5 ) , float2x2( cos337 , -sin337 , sin337 , cos337 )) + float2( 0.5,0.5 );
				float3 temp_output_203_0 = ( WorldViewDirection * _HighlightRotationSpeed_3 );
				float cos201 = cos( temp_output_203_0.x );
				float sin201 = sin( temp_output_203_0.x );
				float2 rotator201 = mul( rotator337 - float2( 0.5,0.5 ) , float2x2( cos201 , -sin201 , sin201 , cos201 )) + float2( 0.5,0.5 );
				float2 Offset202 = ( ( 0.0 - 1 ) * temp_output_203_0.xy * 0.0 ) + rotator201;
				
				float _Smoothness_Instance = UNITY_ACCESS_INSTANCED_PROP(EMDRoleGirl_Eyes_001,_Smoothness);
				
				float3 Albedo = ( ( ( lerpResult271 * 0.02 ) + lerpResult264 + ( ( tex2D( _Highlights, Offset177 ).r * _HighlightIntensity_1 ) + ( tex2D( _Highlights, Offset198 ).g * _HighlightIntensity_2 ) + ( tex2D( _Highlights, Offset202 ).b * _HighlightIntensity_3 ) ) ) * _PupilColorStrength ).rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = _Metallic;
				float Smoothness = _Smoothness_Instance;
				float Occlusion = 1;
				float Alpha = 1;
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
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		
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

			sampler2D _PupilDiffuse;

			VertexOutput vert ( VertexInput v )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.clipPos = TransformObjectToHClip(v.vertex.xyz);
				o.uv = v.texcoord;
				return o;
			}

			half2 ScaleUVsByCenter(half2 uv, float scale)
			{
				float2 center = float2(0.5, 0.5);
				return (uv - center) / scale + center;
			}

			half4 frag ( VertexOutput IN ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);

				float2 newUV = ScaleUVsByCenter(IN.uv.xy, 0.4);
				half4 color = tex2D(_PupilDiffuse, newUV);
				return color;
			}

			ENDHLSL
		}
		
	}


	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	
}