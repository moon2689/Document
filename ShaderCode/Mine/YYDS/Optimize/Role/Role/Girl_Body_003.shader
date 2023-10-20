Shader "TA/Optimize/Role/Role/Girl_Body_003"
{
	Properties
	{
		_Texture("Texture", 2D) = "white" {}
		_DiffuseStrength("DiffuseStrength", Float) = 2
		_BaseColor("BaseColor", Color) = (0.9811321,0,0,0)
		_Normal("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 1)) = 0
		_MaskMap("MaskMap", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
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
		_DarkSide_MaxNew("DarkSide_MaxNew", Range( -2 , 2)) = 0
		_DarkSide_Strength("DarkSide_Strength", Range( 0 , 1)) = 0
		_Tattoo_1("Tattoo_1", 2D) = "white" {}
		_Tattoo_1_Strength("Tattoo_1_Strength", Float) = 0
		_Tattoo_1_move_Y("Tattoo_1_move_Y", Range( -0.8 , -0.35)) = -0.1194
		_Tattoo_1_move_X("Tattoo_1_move_X", Range( -0.8 , -0.2)) = -0.225
		_Tattoo_1_zoom("Tattoo_1_zoom", Range( 3.5 , 30)) = 3.95
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
			#include "../../Library/UnityBRDF_Skin.hlsl"

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
			float4 _Normal_ST;
			float4 _DarkSideColor;
			float4 _HighlightsColor;
			float4 _Texture_ST;
			float4 _BaseColor;
			float4 _3S1Color;
			float4 _MaskMap_ST;
			float4 _3S2Color;
			float _Tattoo_1_zoom;
			float _Tattoo_1_move_Y;
			float _Tattoo_1_move_X;
			float _HighlightsStrength;
			float _HighlightsRange;
			float _AO;
			float _3Sstrength;
			float _3S2_03;
			float _3S2_02;
			float _3S2_01;
			float _3S1_03;
			float _3S1_02;
			float _3S1_01;
			float _DiffuseStrength;
			float _DarkSide_Strength;
			float _DarkSide_MaxNew;
			float _DarkSide_02;
			float _DarkSide_MinNew;
			float _NormalScale;
			float _Tattoo_1_Strength;
			float _Smoothness;
			CBUFFER_END
			sampler2D _Normal;
			sampler2D _Texture;
			sampler2D _MaskMap;
			sampler2D _Tattoo_1;

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

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

				float2 uv_Normal = IN.ase_texcoord8.xy * _Normal_ST.xy + _Normal_ST.zw;
				float3 unpack59 = UnpackNormalScale( tex2D( _Normal, uv_Normal ), _NormalScale );
				unpack59.z = lerp( 1, unpack59.z, saturate(_NormalScale) );
				float3 worldNormal78 = unpack59;
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal334 = worldNormal78;
				float3 worldNormal334 = normalize( float3(dot(tanToWorld0,tanNormal334), dot(tanToWorld1,tanNormal334), dot(tanToWorld2,tanNormal334)) );
				float dotResult301 = dot( worldNormal334 , _MainLightPosition.xyz );
				float4 DarkSideColor401 = saturate( ( (_DarkSide_MinNew + ((dotResult301*( 1.0 + _DarkSide_MinNew ) + _DarkSide_02) - 0.0) * (_DarkSide_MaxNew - _DarkSide_MinNew) / (1.0 - 0.0)) + _DarkSideColor + _DarkSide_Strength ) );
				float2 uv_Texture = IN.ase_texcoord8.xy * _Texture_ST.xy + _Texture_ST.zw;
				float4 Diffuse261 = tex2D( _Texture, uv_Texture );
				float3 tanNormal243 = worldNormal78;
				float3 worldNormal243 = normalize( float3(dot(tanToWorld0,tanNormal243), dot(tanToWorld1,tanNormal243), dot(tanToWorld2,tanNormal243)) );
				float dotResult245 = dot( worldNormal243 , _MainLightPosition.xyz );
				float LightS287 = dotResult245;
				float4 SSSColor_01349 = saturate( ( ( 1.0 - saturate( (LightS287*_3S1_01 + _3S1_02) ) ) * _3S1Color * _3S1_03 ) );
				float4 SSSColor_02347 = ( ( 1.0 - saturate( (LightS287*_3S2_01 + _3S2_02) ) ) * _3S2Color * _3S2_03 );
				float2 uv_MaskMap = IN.ase_texcoord8.xy * _MaskMap_ST.xy + _MaskMap_ST.zw;
				float4 tex2DNode351 = tex2D( _MaskMap, uv_MaskMap );
				float MaskMap_3S354 = tex2DNode351.g;
				float4 temp_output_283_0 = ( ( Diffuse261 * _DiffuseStrength ) + ( ( SSSColor_01349 + SSSColor_02347 ) * MaskMap_3S354 * _3Sstrength ) );
				float MaskMap_AO355 = tex2DNode351.b;
				float4 lerpResult369 = lerp( temp_output_283_0 , ( temp_output_283_0 * MaskMap_AO355 ) , _AO);
				float3 normalizeResult265 = normalize( ( WorldViewDirection + _MainLightPosition.xyz ) );
				float3 tanNormal266 = worldNormal78;
				float3 worldNormal266 = normalize( float3(dot(tanToWorld0,tanNormal266), dot(tanToWorld1,tanNormal266), dot(tanToWorld2,tanNormal266)) );
				float dotResult267 = dot( normalizeResult265 , worldNormal266 );
				float4 Specilar276 = saturate( ( pow( saturate( dotResult267 ) , exp2( ( ( _HighlightsRange * 10.0 ) + 1.0 ) ) ) * _HighlightsColor * _HighlightsStrength ) );
				float2 texCoord421 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0.5,0.5 );
				float2 break416 = (float2( -0.5,-0.5 ) + (texCoord421 - float2( 0,0 )) * (float2( 0.5,0.5 ) - float2( -0.5,-0.5 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult420 = (float2(( break416.x + _Tattoo_1_move_X ) , ( break416.y + _Tattoo_1_move_Y )));
				float4 tex2DNode422 = tex2D( _Tattoo_1, ( ( appendResult420 * _Tattoo_1_zoom ) + 0.5 ) );
				float4 Tattoo_1408 = tex2DNode422;
				float Tattoo_1_A419 = ( tex2DNode422.a * _Tattoo_1_Strength );
				float4 lerpResult426 = lerp( ( ( DarkSideColor401 * lerpResult369 * _BaseColor ) + Specilar276 ) , Tattoo_1408 , Tattoo_1_A419);
				
				float MaskMap_S353 = tex2DNode351.r;
				
				float3 Albedo = lerpResult426.rgb;
				float3 Normal = worldNormal78;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = ( MaskMap_S353 * _Smoothness );
				float Occlusion = 1;
				float Alpha = 1;
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

				half4 color = UniversalFragmentPBR_Skin( inputData, surfaceData);
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
			float4 _Normal_ST;
			float4 _DarkSideColor;
			float4 _HighlightsColor;
			float4 _Texture_ST;
			float4 _BaseColor;
			float4 _3S1Color;
			float4 _MaskMap_ST;
			float4 _3S2Color;
			float _Tattoo_1_zoom;
			float _Tattoo_1_move_Y;
			float _Tattoo_1_move_X;
			float _HighlightsStrength;
			float _HighlightsRange;
			float _AO;
			float _3Sstrength;
			float _3S2_03;
			float _3S2_02;
			float _3S2_01;
			float _3S1_03;
			float _3S1_02;
			float _3S1_01;
			float _DiffuseStrength;
			float _DarkSide_Strength;
			float _DarkSide_MaxNew;
			float _DarkSide_02;
			float _DarkSide_MinNew;
			float _NormalScale;
			float _Tattoo_1_Strength;
			float _Smoothness;
			CBUFFER_END
			sampler2D _Normal;
			sampler2D _Texture;
			sampler2D _MaskMap;
			sampler2D _Tattoo_1;

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

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

				float2 uv_Normal = IN.ase_texcoord8.xy * _Normal_ST.xy + _Normal_ST.zw;
				float3 unpack59 = UnpackNormalScale( tex2D( _Normal, uv_Normal ), _NormalScale );
				unpack59.z = lerp( 1, unpack59.z, saturate(_NormalScale) );
				float3 worldNormal78 = unpack59;
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal334 = worldNormal78;
				float3 worldNormal334 = normalize( float3(dot(tanToWorld0,tanNormal334), dot(tanToWorld1,tanNormal334), dot(tanToWorld2,tanNormal334)) );
				float dotResult301 = dot( worldNormal334 , _MainLightPosition.xyz );
				float4 DarkSideColor401 = saturate( ( (_DarkSide_MinNew + ((dotResult301*( 1.0 + _DarkSide_MinNew ) + _DarkSide_02) - 0.0) * (_DarkSide_MaxNew - _DarkSide_MinNew) / (1.0 - 0.0)) + _DarkSideColor + _DarkSide_Strength ) );
				float2 uv_Texture = IN.ase_texcoord8.xy * _Texture_ST.xy + _Texture_ST.zw;
				float4 Diffuse261 = tex2D( _Texture, uv_Texture );
				float3 tanNormal243 = worldNormal78;
				float3 worldNormal243 = normalize( float3(dot(tanToWorld0,tanNormal243), dot(tanToWorld1,tanNormal243), dot(tanToWorld2,tanNormal243)) );
				float dotResult245 = dot( worldNormal243 , _MainLightPosition.xyz );
				float LightS287 = dotResult245;
				float4 SSSColor_01349 = saturate( ( ( 1.0 - saturate( (LightS287*_3S1_01 + _3S1_02) ) ) * _3S1Color * _3S1_03 ) );
				float4 SSSColor_02347 = ( ( 1.0 - saturate( (LightS287*_3S2_01 + _3S2_02) ) ) * _3S2Color * _3S2_03 );
				float2 uv_MaskMap = IN.ase_texcoord8.xy * _MaskMap_ST.xy + _MaskMap_ST.zw;
				float4 tex2DNode351 = tex2D( _MaskMap, uv_MaskMap );
				float MaskMap_3S354 = tex2DNode351.g;
				float4 temp_output_283_0 = ( ( Diffuse261 * _DiffuseStrength ) + ( ( SSSColor_01349 + SSSColor_02347 ) * MaskMap_3S354 * _3Sstrength ) );
				float MaskMap_AO355 = tex2DNode351.b;
				float4 lerpResult369 = lerp( temp_output_283_0 , ( temp_output_283_0 * MaskMap_AO355 ) , _AO);
				float3 normalizeResult265 = normalize( ( WorldViewDirection + _MainLightPosition.xyz ) );
				float3 tanNormal266 = worldNormal78;
				float3 worldNormal266 = normalize( float3(dot(tanToWorld0,tanNormal266), dot(tanToWorld1,tanNormal266), dot(tanToWorld2,tanNormal266)) );
				float dotResult267 = dot( normalizeResult265 , worldNormal266 );
				float4 Specilar276 = saturate( ( pow( saturate( dotResult267 ) , exp2( ( ( _HighlightsRange * 10.0 ) + 1.0 ) ) ) * _HighlightsColor * _HighlightsStrength ) );
				float2 texCoord421 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0.5,0.5 );
				float2 break416 = (float2( -0.5,-0.5 ) + (texCoord421 - float2( 0,0 )) * (float2( 0.5,0.5 ) - float2( -0.5,-0.5 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult420 = (float2(( break416.x + _Tattoo_1_move_X ) , ( break416.y + _Tattoo_1_move_Y )));
				float4 tex2DNode422 = tex2D( _Tattoo_1, ( ( appendResult420 * _Tattoo_1_zoom ) + 0.5 ) );
				float4 Tattoo_1408 = tex2DNode422;
				float Tattoo_1_A419 = ( tex2DNode422.a * _Tattoo_1_Strength );
				float4 lerpResult426 = lerp( ( ( DarkSideColor401 * lerpResult369 * _BaseColor ) + Specilar276 ) , Tattoo_1408 , Tattoo_1_A419);
				
				float MaskMap_S353 = tex2DNode351.r;
				
				float3 Albedo = lerpResult426.rgb * 0.5;
				float3 Normal = worldNormal78;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = ( MaskMap_S353 * _Smoothness );
				float Occlusion = 1;
				float Alpha = 1;
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

				//half4 color = UniversalFragmentPBR( inputData, surfaceData);
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

			sampler2D _Texture;

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

				half4 color = tex2D(_Texture, IN.uv.xy);
				return color;
			}

			ENDHLSL
		}
		
	}



	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	
}
