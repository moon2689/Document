Shader "TA/Optimize/Role/Role/Girl_Range_001"
{
	Properties
	{
		_Mask_001("Mask_001", 2D) = "white" {}
		_FresnelBiss("FresnelBiss", Range( -0.5 , 0.5)) = 0
		_FresnelScale("FresnelScale", Float) = 0.5
		_FresnelPower("FresnelPower", Float) = 2
		_FresnelColor("FresnelColor", Color) = (0.259434,1,0.9389895,0)
		_skybox_001("skybox_001", CUBE) = "white" {}
		_MetallicReflection("MetallicReflection", Float) = 1
		_MetallicReflectionColor("MetallicReflectionColor", Color) = (1,1,1,0)
		_RangeSmoothness("RangeSmoothness", Range( 0 , 1)) = 0.8117647
		_RangeMetallic("RangeMetallic", Range( 0 , 1)) = 0.8117647
		_Reflection("Reflection", Float) = 1
		_ReflectionColor("ReflectionColor", Color) = (1,1,1,0)
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_Range_01("Range_01", Float) = 0
		_Range_02("Range_02", Float) = 0
		_Range_03("Range_03", Float) = 0
		_Range_04("Range_04", Float) = 0
		_Range_05("Range_05", Float) = 0
		_Range_06("Range_06", Float) = 0
		_Range_07("Range_07", Float) = 0
		_Range_08("Range_08", Float) = 0
		_Range_09("Range_09", Float) = 0
		_Range_10("Range_10", Float) = 0
		_Range_11("Range_11", Float) = 0
		_Range_12("Range_12", Float) = 0
		_Range_13("Range_13", Float) = 0
		_Range_14("Range_14", Float) = 0
		_Range_15("Range_15", Float) = 0
		_Range_16("Range_16", Float) = 0
		_Range_17("Range_17", Float) = 0
		_Range_18("Range_18", Float) = 0
		_Range_19("Range_19", Float) = 0
		_Range_20("Range_20", Float) = 0
		_Range_21("Range_21", Float) = 0
		_Range_22("Range_22", Float) = 0
		_Range_23("Range_23", Float) = 0
		_Range_24("Range_24", Float) = 0
		_Range_25("Range_25", Float) = 0
		_Range_26("Range_26", Float) = 0
		_Range_27("Range_27", Float) = 0
		_Range_28("Range_28", Float) = 0
		_Tattoo_1("Tattoo_1", 2D) = "white" {}
		_Tattoo_1_Normal("Tattoo_1_Normal", 2D) = "bump" {}
		_Tattoo_1MaskMap("Tattoo_1MaskMap", 2D) = "white" {}
		_Tattoo_1_Strength("Tattoo_1_Strength", Float) = 3
		_Tattoo_1_Visibility("Tattoo_1_Visibility", Float) = 0
		_Tattoo_1_Image("Tattoo_1_Image", Float) = 0
		_Tattoo_1_Color("Tattoo_1_Color", Color) = (1,1,1,0)
		_Tattoo_1_move_X("Tattoo_1_move_X", Range( -0.8 , -0.2)) = -0.225
		_Tattoo_1_move_Y("Tattoo_1_move_Y", Range( -0.8 , -0.35)) = -0.1194
		_Tattoo_1_Rotate("Tattoo_1_Rotate", Range( -3.14 , 3.14)) = 0
		_Tattoo_1_zoom("Tattoo_1_zoom", Range( 2 , 50)) = 3.95
		_Tattoo_2("Tattoo_2", 2D) = "white" {}
		_Tattoo_2_Normal("Tattoo_2_Normal", 2D) = "bump" {}
		_Tattoo_2MaskMap("Tattoo_2MaskMap", 2D) = "white" {}
		_Tattoo_2_Strength("Tattoo_2_Strength", Float) = 3
		_Tattoo_2_Visibility("Tattoo_2_Visibility", Float) = 0
		_Tattoo_2_Image("Tattoo_2_Image", Float) = 0
		_Tattoo_2_Color("Tattoo_2_Color", Color) = (1,1,1,0)
		_Tattoo_2_move_X("Tattoo_2_move_X", Range( -0.8 , -0.2)) = -0.225
		_Tattoo_2_move_Y("Tattoo_2_move_Y", Range( -0.8 , -0.35)) = -0.1194
		_Tattoo_2_Rotate("Tattoo_2_Rotate", Range( -3.14 , 3.14)) = 0
		_Tattoo_2_zoom("Tattoo_2_zoom", Range( 3.5 , 50)) = 3.95
		_Normal_0_001("Normal_0_001", 2D) = "bump" {}
	}

	SubShader
	{
		LOD 0
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Pass
		{
			Name "ExtraPrePass"
			
			Blend One One, One OneMinusSrcAlpha

			HLSLPROGRAM
			
			#pragma multi_compile_instancing

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float4 shadowCoord : TEXCOORD1;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Normal_0_001_ST;
			float4 _FresnelColor;
			float4 _MetallicReflectionColor;
			float4 _ReflectionColor;
			float4 _Tattoo_2_Color;
			float4 _Tattoo_1_Color;
			float _FresnelBiss;
			float _Range_24;
			float _Range_25;
			float _Range_26;
			float _Range_27;
			float _Range_28;
			float _Tattoo_1_move_X;
			float _Tattoo_1_move_Y;
			float _Tattoo_1_zoom;
			float _Tattoo_1_Rotate;
			float _Tattoo_2_move_X;
			float _Tattoo_1_Image;
			float _Range_23;
			float _Tattoo_2_move_Y;
			float _Tattoo_2_zoom;
			float _Tattoo_2_Rotate;
			float _Tattoo_2_Strength;
			float _Tattoo_2_Image;
			float _Tattoo_2_Visibility;
			float _Tattoo_1_Visibility;
			float _Tattoo_1_Strength;
			float _Range_22;
			float _Range_20;
			float _RangeMetallic;
			float _FresnelScale;
			float _FresnelPower;
			float _MetallicReflection;
			float _Reflection;
			float _Range_01;
			float _Range_02;
			float _Range_03;
			float _Range_04;
			float _Range_05;
			float _Range_06;
			float _Range_07;
			float _Range_08;
			float _Range_09;
			float _Range_10;
			float _Range_11;
			float _Range_12;
			float _Range_13;
			float _Range_14;
			float _Range_15;
			float _Range_16;
			float _Range_17;
			float _Range_18;
			float _Range_19;
			float _Range_21;
			float _RangeSmoothness;
			CBUFFER_END
			sampler2D _TextureSample0;
			samplerCUBE _skybox_001;
			sampler2D _Mask_001;


			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				o.ase_texcoord4.xy = v.ase_texcoord1.xy;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.zw = 0;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				o.worldPos = positionWS;
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				o.clipPos = positionCS;
				return o;
			}
			
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}

			half4 frag ( VertexOutput IN , FRONT_FACE_TYPE ase_vface : FRONT_FACE_SEMANTIC ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );

				float3 WorldPosition = IN.worldPos;
				float4 ShadowCoords = IN.shadowCoord;
				float3 ase_worldViewDir = GetWorldSpaceNormalizeViewDir(WorldPosition);
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV46 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode46 = ( _FresnelBiss + _FresnelScale * pow( abs(1.0 - fresnelNdotV46), _FresnelPower ) );
				float4 temp_output_50_0 = ( fresnelNode46 * _FresnelColor );
				float4 switchResult117 = (((ase_vface>0)?(temp_output_50_0):(( temp_output_50_0 * float4( 0.2735849,0.2735849,0.2735849,0 ) ))));
				float4 switchResult119 = (((ase_vface>0)?(switchResult117):(float4( 0,0,0,0 ))));
				float2 texCoord764 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode255 = tex2D( _TextureSample0, texCoord764 );
				float Diffuse_mask_A259 = tex2DNode255.a;
				float3 ase_worldReflection = reflect(-ase_worldViewDir, ase_worldNormal);
				float cos427 = cos( 0.3 * _Time.y );
				float sin427 = sin( 0.3 * _Time.y );
				float2 rotator427 = mul( ase_worldReflection.xy - float2( 0,0 ) , float2x2( cos427 , -sin427 , sin427 , cos427 )) + float2( 0,0 );
				float4 texCUBENode78 = texCUBE( _skybox_001, float3( rotator427 ,  0.0 ) );
				float Diffuse_mask_R256 = tex2DNode255.r;
				float4 temp_output_74_0 = ( ( ( switchResult119 + ( Diffuse_mask_A259 * ( _MetallicReflection * _MetallicReflectionColor * texCUBENode78 ) ) + ( ( texCUBENode78 * _ReflectionColor ) * _Reflection ) ) * Diffuse_mask_R256 ) + ( 1.0 - Diffuse_mask_R256 ) );
				float Diffuse_mask_B258 = tex2DNode255.b;
				float2 texCoord41_g570 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g570 = tex2D( _Mask_001, texCoord41_g570 );
				float3 appendResult35_g570 = (float3(tex2DNode19_g570.r , tex2DNode19_g570.g , tex2DNode19_g570.b));
				float2 texCoord15_g570 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g570 = tex2D( _Mask_001, ( texCoord15_g570 + float2( 0.1,0.78 ) ) );
				float3 appendResult36_g570 = (float3(tex2DNode18_g570.r , tex2DNode18_g570.g , tex2DNode18_g570.b));
				float2 texCoord41_g562 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g562 = tex2D( _Mask_001, texCoord41_g562 );
				float3 appendResult35_g562 = (float3(tex2DNode19_g562.r , tex2DNode19_g562.g , tex2DNode19_g562.b));
				float2 texCoord15_g562 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g562 = tex2D( _Mask_001, ( texCoord15_g562 + float2( 0.02,0.62 ) ) );
				float3 appendResult36_g562 = (float3(tex2DNode18_g562.r , tex2DNode18_g562.g , tex2DNode18_g562.b));
				float2 texCoord41_g574 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g574 = tex2D( _Mask_001, texCoord41_g574 );
				float3 appendResult35_g574 = (float3(tex2DNode19_g574.r , tex2DNode19_g574.g , tex2DNode19_g574.b));
				float2 texCoord15_g574 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g574 = tex2D( _Mask_001, ( texCoord15_g574 + float2( 0.02,0.55 ) ) );
				float3 appendResult36_g574 = (float3(tex2DNode18_g574.r , tex2DNode18_g574.g , tex2DNode18_g574.b));
				float2 texCoord41_g578 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g578 = tex2D( _Mask_001, texCoord41_g578 );
				float3 appendResult35_g578 = (float3(tex2DNode19_g578.r , tex2DNode19_g578.g , tex2DNode19_g578.b));
				float2 texCoord15_g578 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g578 = tex2D( _Mask_001, ( texCoord15_g578 + float2( 0.02,0.47 ) ) );
				float3 appendResult36_g578 = (float3(tex2DNode18_g578.r , tex2DNode18_g578.g , tex2DNode18_g578.b));
				float2 texCoord41_g565 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g565 = tex2D( _Mask_001, texCoord41_g565 );
				float3 appendResult35_g565 = (float3(tex2DNode19_g565.r , tex2DNode19_g565.g , tex2DNode19_g565.b));
				float2 texCoord15_g565 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g565 = tex2D( _Mask_001, ( texCoord15_g565 + float2( 0.02,0.39 ) ) );
				float3 appendResult36_g565 = (float3(tex2DNode18_g565.r , tex2DNode18_g565.g , tex2DNode18_g565.b));
				float2 texCoord41_g563 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g563 = tex2D( _Mask_001, texCoord41_g563 );
				float3 appendResult35_g563 = (float3(tex2DNode19_g563.r , tex2DNode19_g563.g , tex2DNode19_g563.b));
				float2 texCoord15_g563 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g563 = tex2D( _Mask_001, ( texCoord15_g563 + float2( 0.02,0.32 ) ) );
				float3 appendResult36_g563 = (float3(tex2DNode18_g563.r , tex2DNode18_g563.g , tex2DNode18_g563.b));
				float2 texCoord41_g569 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g569 = tex2D( _Mask_001, texCoord41_g569 );
				float3 appendResult35_g569 = (float3(tex2DNode19_g569.r , tex2DNode19_g569.g , tex2DNode19_g569.b));
				float2 texCoord15_g569 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g569 = tex2D( _Mask_001, ( texCoord15_g569 + float2( 0.02,0.26 ) ) );
				float3 appendResult36_g569 = (float3(tex2DNode18_g569.r , tex2DNode18_g569.g , tex2DNode18_g569.b));
				float2 texCoord41_g579 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g579 = tex2D( _Mask_001, texCoord41_g579 );
				float3 appendResult35_g579 = (float3(tex2DNode19_g579.r , tex2DNode19_g579.g , tex2DNode19_g579.b));
				float2 texCoord15_g579 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g579 = tex2D( _Mask_001, ( texCoord15_g579 + float2( 0.02,0.15 ) ) );
				float3 appendResult36_g579 = (float3(tex2DNode18_g579.r , tex2DNode18_g579.g , tex2DNode18_g579.b));
				float2 texCoord41_g576 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g576 = tex2D( _Mask_001, texCoord41_g576 );
				float3 appendResult35_g576 = (float3(tex2DNode19_g576.r , tex2DNode19_g576.g , tex2DNode19_g576.b));
				float2 texCoord15_g576 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g576 = tex2D( _Mask_001, ( texCoord15_g576 + float2( 0.17,0.27 ) ) );
				float3 appendResult36_g576 = (float3(tex2DNode18_g576.r , tex2DNode18_g576.g , tex2DNode18_g576.b));
				float2 texCoord41_g568 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g568 = tex2D( _Mask_001, texCoord41_g568 );
				float3 appendResult35_g568 = (float3(tex2DNode19_g568.r , tex2DNode19_g568.g , tex2DNode19_g568.b));
				float2 texCoord15_g568 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g568 = tex2D( _Mask_001, ( texCoord15_g568 + float2( 0.07,0.25 ) ) );
				float3 appendResult36_g568 = (float3(tex2DNode18_g568.r , tex2DNode18_g568.g , tex2DNode18_g568.b));
				float2 texCoord41_g587 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g587 = tex2D( _Mask_001, texCoord41_g587 );
				float3 appendResult35_g587 = (float3(tex2DNode19_g587.r , tex2DNode19_g587.g , tex2DNode19_g587.b));
				float2 texCoord15_g587 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g587 = tex2D( _Mask_001, ( texCoord15_g587 + float2( 0.12,0.27 ) ) );
				float3 appendResult36_g587 = (float3(tex2DNode18_g587.r , tex2DNode18_g587.g , tex2DNode18_g587.b));
				float2 texCoord41_g585 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g585 = tex2D( _Mask_001, texCoord41_g585 );
				float3 appendResult35_g585 = (float3(tex2DNode19_g585.r , tex2DNode19_g585.g , tex2DNode19_g585.b));
				float2 texCoord15_g585 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g585 = tex2D( _Mask_001, ( texCoord15_g585 + float2( 0.09,0.315 ) ) );
				float3 appendResult36_g585 = (float3(tex2DNode18_g585.r , tex2DNode18_g585.g , tex2DNode18_g585.b));
				float2 texCoord41_g584 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g584 = tex2D( _Mask_001, texCoord41_g584 );
				float3 appendResult35_g584 = (float3(tex2DNode19_g584.r , tex2DNode19_g584.g , tex2DNode19_g584.b));
				float2 texCoord15_g584 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g584 = tex2D( _Mask_001, ( texCoord15_g584 + float2( 0.1,0.3529929 ) ) );
				float3 appendResult36_g584 = (float3(tex2DNode18_g584.r , tex2DNode18_g584.g , tex2DNode18_g584.b));
				float2 texCoord41_g583 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g583 = tex2D( _Mask_001, texCoord41_g583 );
				float3 appendResult35_g583 = (float3(tex2DNode19_g583.r , tex2DNode19_g583.g , tex2DNode19_g583.b));
				float2 texCoord15_g583 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g583 = tex2D( _Mask_001, ( texCoord15_g583 + float2( 0.07,0.4 ) ) );
				float3 appendResult36_g583 = (float3(tex2DNode18_g583.r , tex2DNode18_g583.g , tex2DNode18_g583.b));
				float2 texCoord41_g588 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g588 = tex2D( _Mask_001, texCoord41_g588 );
				float3 appendResult35_g588 = (float3(tex2DNode19_g588.r , tex2DNode19_g588.g , tex2DNode19_g588.b));
				float2 texCoord15_g588 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g588 = tex2D( _Mask_001, ( texCoord15_g588 + float2( 0.34,0.25 ) ) );
				float3 appendResult36_g588 = (float3(tex2DNode18_g588.r , tex2DNode18_g588.g , tex2DNode18_g588.b));
				float2 texCoord41_g581 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g581 = tex2D( _Mask_001, texCoord41_g581 );
				float3 appendResult35_g581 = (float3(tex2DNode19_g581.r , tex2DNode19_g581.g , tex2DNode19_g581.b));
				float2 texCoord15_g581 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g581 = tex2D( _Mask_001, ( texCoord15_g581 + float2( 0.48,0.36 ) ) );
				float3 appendResult36_g581 = (float3(tex2DNode18_g581.r , tex2DNode18_g581.g , tex2DNode18_g581.b));
				float2 texCoord41_g586 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g586 = tex2D( _Mask_001, texCoord41_g586 );
				float3 appendResult35_g586 = (float3(tex2DNode19_g586.r , tex2DNode19_g586.g , tex2DNode19_g586.b));
				float2 texCoord15_g586 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g586 = tex2D( _Mask_001, ( texCoord15_g586 + float2( 0.19,0.32 ) ) );
				float3 appendResult36_g586 = (float3(tex2DNode18_g586.r , tex2DNode18_g586.g , tex2DNode18_g586.b));
				float2 texCoord41_g589 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g589 = tex2D( _Mask_001, texCoord41_g589 );
				float3 appendResult35_g589 = (float3(tex2DNode19_g589.r , tex2DNode19_g589.g , tex2DNode19_g589.b));
				float2 texCoord15_g589 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g589 = tex2D( _Mask_001, ( texCoord15_g589 + float2( 0.5,0.61 ) ) );
				float3 appendResult36_g589 = (float3(tex2DNode18_g589.r , tex2DNode18_g589.g , tex2DNode18_g589.b));
				float2 texCoord41_g582 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g582 = tex2D( _Mask_001, texCoord41_g582 );
				float3 appendResult35_g582 = (float3(tex2DNode19_g582.r , tex2DNode19_g582.g , tex2DNode19_g582.b));
				float2 texCoord15_g582 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g582 = tex2D( _Mask_001, ( texCoord15_g582 + float2( 0.16,0.38 ) ) );
				float3 appendResult36_g582 = (float3(tex2DNode18_g582.r , tex2DNode18_g582.g , tex2DNode18_g582.b));
				float2 texCoord41_g580 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g580 = tex2D( _Mask_001, texCoord41_g580 );
				float3 appendResult35_g580 = (float3(tex2DNode19_g580.r , tex2DNode19_g580.g , tex2DNode19_g580.b));
				float2 texCoord15_g580 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g580 = tex2D( _Mask_001, ( texCoord15_g580 + float2( 0.34,0.53 ) ) );
				float3 appendResult36_g580 = (float3(tex2DNode18_g580.r , tex2DNode18_g580.g , tex2DNode18_g580.b));
				float2 texCoord41_g571 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g571 = tex2D( _Mask_001, texCoord41_g571 );
				float3 appendResult35_g571 = (float3(tex2DNode19_g571.r , tex2DNode19_g571.g , tex2DNode19_g571.b));
				float2 texCoord15_g571 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g571 = tex2D( _Mask_001, ( texCoord15_g571 + float2( 0.13,0.6 ) ) );
				float3 appendResult36_g571 = (float3(tex2DNode18_g571.r , tex2DNode18_g571.g , tex2DNode18_g571.b));
				float2 texCoord41_g573 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g573 = tex2D( _Mask_001, texCoord41_g573 );
				float3 appendResult35_g573 = (float3(tex2DNode19_g573.r , tex2DNode19_g573.g , tex2DNode19_g573.b));
				float2 texCoord15_g573 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g573 = tex2D( _Mask_001, ( texCoord15_g573 + float2( 0.19,0.54 ) ) );
				float3 appendResult36_g573 = (float3(tex2DNode18_g573.r , tex2DNode18_g573.g , tex2DNode18_g573.b));
				float2 texCoord41_g572 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g572 = tex2D( _Mask_001, texCoord41_g572 );
				float3 appendResult35_g572 = (float3(tex2DNode19_g572.r , tex2DNode19_g572.g , tex2DNode19_g572.b));
				float2 texCoord15_g572 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g572 = tex2D( _Mask_001, ( texCoord15_g572 + float2( 0.31,0.53 ) ) );
				float3 appendResult36_g572 = (float3(tex2DNode18_g572.r , tex2DNode18_g572.g , tex2DNode18_g572.b));
				float2 texCoord41_g567 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g567 = tex2D( _Mask_001, texCoord41_g567 );
				float3 appendResult35_g567 = (float3(tex2DNode19_g567.r , tex2DNode19_g567.g , tex2DNode19_g567.b));
				float2 texCoord15_g567 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g567 = tex2D( _Mask_001, ( texCoord15_g567 + float2( 0.15,0.65 ) ) );
				float3 appendResult36_g567 = (float3(tex2DNode18_g567.r , tex2DNode18_g567.g , tex2DNode18_g567.b));
				float2 texCoord41_g564 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g564 = tex2D( _Mask_001, texCoord41_g564 );
				float3 appendResult35_g564 = (float3(tex2DNode19_g564.r , tex2DNode19_g564.g , tex2DNode19_g564.b));
				float2 texCoord15_g564 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g564 = tex2D( _Mask_001, ( texCoord15_g564 + float2( 0.31,0.69 ) ) );
				float3 appendResult36_g564 = (float3(tex2DNode18_g564.r , tex2DNode18_g564.g , tex2DNode18_g564.b));
				float2 texCoord41_g575 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g575 = tex2D( _Mask_001, texCoord41_g575 );
				float3 appendResult35_g575 = (float3(tex2DNode19_g575.r , tex2DNode19_g575.g , tex2DNode19_g575.b));
				float2 texCoord15_g575 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g575 = tex2D( _Mask_001, ( texCoord15_g575 + float2( 0.07,0.68 ) ) );
				float3 appendResult36_g575 = (float3(tex2DNode18_g575.r , tex2DNode18_g575.g , tex2DNode18_g575.b));
				float2 texCoord41_g577 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g577 = tex2D( _Mask_001, texCoord41_g577 );
				float3 appendResult35_g577 = (float3(tex2DNode19_g577.r , tex2DNode19_g577.g , tex2DNode19_g577.b));
				float2 texCoord15_g577 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g577 = tex2D( _Mask_001, ( texCoord15_g577 + float2( 0.63,0.44 ) ) );
				float3 appendResult36_g577 = (float3(tex2DNode18_g577.r , tex2DNode18_g577.g , tex2DNode18_g577.b));
				float2 texCoord41_g566 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g566 = tex2D( _Mask_001, texCoord41_g566 );
				float3 appendResult35_g566 = (float3(tex2DNode19_g566.r , tex2DNode19_g566.g , tex2DNode19_g566.b));
				float2 texCoord15_g566 = IN.ase_texcoord4.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g566 = tex2D( _Mask_001, ( texCoord15_g566 + float2( 0.77,0.64 ) ) );
				float3 appendResult36_g566 = (float3(tex2DNode18_g566.r , tex2DNode18_g566.g , tex2DNode18_g566.b));
				float all180 = ( ( ( saturate( ( 1.0 - ( ( distance( appendResult35_g570 , appendResult36_g570 ) - 0.02 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_01 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g562 , appendResult36_g562 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_02 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g574 , appendResult36_g574 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_03 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g578 , appendResult36_g578 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_04 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g565 , appendResult36_g565 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_05 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g563 , appendResult36_g563 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_06 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g569 , appendResult36_g569 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_07 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g579 , appendResult36_g579 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_08 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g576 , appendResult36_g576 ) - 0.02 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_09 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g568 , appendResult36_g568 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_10 ) ) + ( ( saturate( ( 1.0 - ( ( distance( appendResult35_g587 , appendResult36_g587 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_11 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g585 , appendResult36_g585 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_12 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g584 , appendResult36_g584 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_13 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g583 , appendResult36_g583 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_14 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g588 , appendResult36_g588 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_15 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g581 , appendResult36_g581 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_16 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g586 , appendResult36_g586 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_17 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g589 , appendResult36_g589 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_18 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g582 , appendResult36_g582 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_19 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g580 , appendResult36_g580 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_20 ) ) + ( ( saturate( ( 1.0 - ( ( distance( appendResult35_g571 , appendResult36_g571 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_21 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g573 , appendResult36_g573 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_22 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g572 , appendResult36_g572 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_23 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g567 , appendResult36_g567 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_24 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g564 , appendResult36_g564 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_25 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g575 , appendResult36_g575 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_26 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g577 , appendResult36_g577 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_27 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g566 , appendResult36_g566 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_28 ) ) );
				float Range_A606 = ( ( ( Diffuse_mask_R256 * 0.6 ) + ( Diffuse_mask_B258 * 0.1 ) ) * all180 );
				float4 temp_output_994_0 = saturate( ( temp_output_74_0 * Range_A606 ) );
				
				float3 Color = temp_output_994_0.rgb;
				float Alpha = 1;

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _SHADOWS_SOFT

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
				float4 shadowCoord : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				float4 ase_texcoord8 : TEXCOORD8;
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Normal_0_001_ST;
			float4 _FresnelColor;
			float4 _MetallicReflectionColor;
			float4 _ReflectionColor;
			float4 _Tattoo_2_Color;
			float4 _Tattoo_1_Color;
			float _FresnelBiss;
			float _Range_24;
			float _Range_25;
			float _Range_26;
			float _Range_27;
			float _Range_28;
			float _Tattoo_1_move_X;
			float _Tattoo_1_move_Y;
			float _Tattoo_1_zoom;
			float _Tattoo_1_Rotate;
			float _Tattoo_2_move_X;
			float _Tattoo_1_Image;
			float _Range_23;
			float _Tattoo_2_move_Y;
			float _Tattoo_2_zoom;
			float _Tattoo_2_Rotate;
			float _Tattoo_2_Strength;
			float _Tattoo_2_Image;
			float _Tattoo_2_Visibility;
			float _Tattoo_1_Visibility;
			float _Tattoo_1_Strength;
			float _Range_22;
			float _Range_20;
			float _RangeMetallic;
			float _FresnelScale;
			float _FresnelPower;
			float _MetallicReflection;
			float _Reflection;
			float _Range_01;
			float _Range_02;
			float _Range_03;
			float _Range_04;
			float _Range_05;
			float _Range_06;
			float _Range_07;
			float _Range_08;
			float _Range_09;
			float _Range_10;
			float _Range_11;
			float _Range_12;
			float _Range_13;
			float _Range_14;
			float _Range_15;
			float _Range_16;
			float _Range_17;
			float _Range_18;
			float _Range_19;
			float _Range_21;
			float _RangeSmoothness;
			CBUFFER_END
			sampler2D _TextureSample0;
			samplerCUBE _skybox_001;
			sampler2D _Tattoo_1;
			sampler2D _Tattoo_1MaskMap;
			sampler2D _Tattoo_2;
			sampler2D _Tattoo_2MaskMap;
			sampler2D _Mask_001;
			sampler2D _Normal_0_001;
			sampler2D _Tattoo_1_Normal;
			sampler2D _Tattoo_2_Normal;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord8.xy = v.texcoord1.xy;
				o.ase_texcoord9.xyz = v.texcoord.xyz;
				o.ase_texcoord8.zw = 0;
				o.ase_texcoord9.w = 0;
				
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
				
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				
				o.clipPos = positionCS;
				return o;
			}
			
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}

			half4 frag ( VertexOutput IN , FRONT_FACE_TYPE ase_vface : FRONT_FACE_SEMANTIC ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				
				float3 WorldNormal = normalize( IN.tSpace0.xyz );
				float3 WorldTangent = IN.tSpace1.xyz;
				float3 WorldBiTangent = IN.tSpace2.xyz;
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = GetWorldSpaceNormalizeViewDir(WorldPosition);
				float4 ShadowCoords = IN.shadowCoord;

				float fresnelNdotV46 = dot( WorldNormal, WorldViewDirection );
				float fresnelNode46 = ( _FresnelBiss + _FresnelScale * pow( abs(1.0 - fresnelNdotV46), _FresnelPower ) );
				float4 temp_output_50_0 = ( fresnelNode46 * _FresnelColor );
				float4 switchResult117 = (((ase_vface>0)?(temp_output_50_0):(( temp_output_50_0 * float4( 0.2735849,0.2735849,0.2735849,0 ) ))));
				float4 switchResult119 = (((ase_vface>0)?(switchResult117):(float4( 0,0,0,0 ))));
				float2 texCoord764 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode255 = tex2D( _TextureSample0, texCoord764 );
				float Diffuse_mask_A259 = tex2DNode255.a;
				float3 ase_worldReflection = reflect(-WorldViewDirection, WorldNormal);
				float cos427 = cos( 0.3 * _Time.y );
				float sin427 = sin( 0.3 * _Time.y );
				float2 rotator427 = mul( ase_worldReflection.xy - float2( 0,0 ) , float2x2( cos427 , -sin427 , sin427 , cos427 )) + float2( 0,0 );
				float4 texCUBENode78 = texCUBE( _skybox_001, float3( rotator427 ,  0.0 ) );
				float Diffuse_mask_R256 = tex2DNode255.r;
				float4 temp_output_74_0 = ( ( ( switchResult119 + ( Diffuse_mask_A259 * ( _MetallicReflection * _MetallicReflectionColor * texCUBENode78 ) ) + ( ( texCUBENode78 * _ReflectionColor ) * _Reflection ) ) * Diffuse_mask_R256 ) + ( 1.0 - Diffuse_mask_R256 ) );
				float2 texCoord445 = IN.ase_texcoord9.xyz.xy * float2( 1,1 ) + float2( 0.5,0.5 );
				float2 break451 = (float2( -0.5,-0.5 ) + (texCoord445 - float2( 0,0 )) * (float2( 0.5,0.5 ) - float2( -0.5,-0.5 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult484 = (float2(( break451.x + _Tattoo_1_move_X ) , ( break451.y + _Tattoo_1_move_Y )));
				float2 _Vector28 = float2(0.5,0.5);
				float cos501 = cos( _Tattoo_1_Rotate );
				float sin501 = sin( _Tattoo_1_Rotate );
				float2 rotator501 = mul( ( ( appendResult484 * _Tattoo_1_zoom ) + 0.5 ) - _Vector28 , float2x2( cos501 , -sin501 , sin501 , cos501 )) + _Vector28;
				float2 Tattoo_1_UV_1504 = rotator501;
				float4 tex2DNode510 = tex2D( _Tattoo_1, Tattoo_1_UV_1504 );
				float2 appendResult474 = (float2(( ( 1.0 - break451.x ) + _Tattoo_1_move_X ) , ( break451.y + _Tattoo_1_move_Y )));
				float cos494 = cos( _Tattoo_1_Rotate );
				float sin494 = sin( _Tattoo_1_Rotate );
				float2 rotator494 = mul( ( ( appendResult474 * _Tattoo_1_zoom ) + 0.5 ) - _Vector28 , float2x2( cos494 , -sin494 , sin494 , cos494 )) + _Vector28;
				float2 Tattoo_1_UV_2503 = rotator494;
				float4 tex2DNode507 = tex2D( _Tattoo_1, Tattoo_1_UV_2503 );
				float Tattoo_1_A_2509 = tex2DNode507.a;
				float Tattoo_1_Image511 = _Tattoo_1_Image;
				float temp_output_517_0 = ( Tattoo_1_A_2509 * Tattoo_1_Image511 );
				float4 lerpResult602 = lerp( ( tex2DNode510 * _Tattoo_1_Color * _Tattoo_1_Strength ) , ( _Tattoo_1_Color * tex2DNode507 * _Tattoo_1_Strength ) , temp_output_517_0);
				float4 Tattoo_1537 = lerpResult602;
				float4 tex2DNode545 = tex2D( _Tattoo_1MaskMap, Tattoo_1_UV_1504 );
				float4 tex2DNode548 = tex2D( _Tattoo_1MaskMap, Tattoo_1_UV_2503 );
				float lerpResult661 = lerp( tex2DNode545.b , tex2DNode548.b , tex2DNode548.b);
				float Tattoo_1MaskMap_AO564 = lerpResult661;
				float2 texCoord446 = IN.ase_texcoord9.xyz.xy * float2( 1,1 ) + float2( 0.5,0.5 );
				float2 break452 = (float2( -0.5,-0.5 ) + (texCoord446 - float2( 0,0 )) * (float2( 0.5,0.5 ) - float2( -0.5,-0.5 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult490 = (float2(( break452.x + _Tattoo_2_move_X ) , ( break452.y + _Tattoo_2_move_Y )));
				float2 _Vector29 = float2(0.5,0.5);
				float cos505 = cos( _Tattoo_2_Rotate );
				float sin505 = sin( _Tattoo_2_Rotate );
				float2 rotator505 = mul( ( ( appendResult490 * _Tattoo_2_zoom ) + 0.5 ) - _Vector29 , float2x2( cos505 , -sin505 , sin505 , cos505 )) + _Vector29;
				float2 Tattoo_2_UV_1514 = rotator505;
				float4 tex2DNode518 = tex2D( _Tattoo_2, Tattoo_2_UV_1514 );
				float2 appendResult485 = (float2(( ( 1.0 - break452.x ) + _Tattoo_2_move_X ) , ( break452.y + _Tattoo_2_move_Y )));
				float cos500 = cos( _Tattoo_2_Rotate );
				float sin500 = sin( _Tattoo_2_Rotate );
				float2 rotator500 = mul( ( ( appendResult485 * _Tattoo_2_zoom ) + 0.5 ) - _Vector29 , float2x2( cos500 , -sin500 , sin500 , cos500 )) + _Vector29;
				float2 Tattoo_2_UV_2508 = rotator500;
				float4 tex2DNode512 = tex2D( _Tattoo_2, Tattoo_2_UV_2508 );
				float Tattoo_2_A_2516 = tex2DNode512.a;
				float Tattoo_2_Image519 = _Tattoo_2_Image;
				float temp_output_522_0 = ( Tattoo_2_A_2516 * Tattoo_2_Image519 );
				float4 lerpResult615 = lerp( ( tex2DNode518 * _Tattoo_2_Color * _Tattoo_2_Strength ) , ( _Tattoo_2_Color * tex2DNode512 * _Tattoo_2_Strength ) , temp_output_522_0);
				float4 Tattoo_2539 = lerpResult615;
				float4 tex2DNode551 = tex2D( _Tattoo_2MaskMap, Tattoo_2_UV_1514 );
				float4 tex2DNode555 = tex2D( _Tattoo_2MaskMap, Tattoo_2_UV_2508 );
				float lerpResult664 = lerp( tex2DNode551.b , tex2DNode555.b , tex2DNode555.b);
				float Tattoo_2MaskMap_AO568 = lerpResult664;
				float Tattoo_2_A_1521 = tex2DNode518.a;
				float Tattoo_2_A529 = saturate( ( ( Tattoo_2_A_1521 + temp_output_522_0 ) * _Tattoo_2_Visibility ) );
				float4 lerpResult631 = lerp( ( Tattoo_1537 * Tattoo_1MaskMap_AO564 ) , ( Tattoo_2539 * Tattoo_2MaskMap_AO568 ) , Tattoo_2_A529);
				float Diffuse_mask_B258 = tex2DNode255.b;
				float2 texCoord41_g570 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g570 = tex2D( _Mask_001, texCoord41_g570 );
				float3 appendResult35_g570 = (float3(tex2DNode19_g570.r , tex2DNode19_g570.g , tex2DNode19_g570.b));
				float2 texCoord15_g570 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g570 = tex2D( _Mask_001, ( texCoord15_g570 + float2( 0.1,0.78 ) ) );
				float3 appendResult36_g570 = (float3(tex2DNode18_g570.r , tex2DNode18_g570.g , tex2DNode18_g570.b));
				float2 texCoord41_g562 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g562 = tex2D( _Mask_001, texCoord41_g562 );
				float3 appendResult35_g562 = (float3(tex2DNode19_g562.r , tex2DNode19_g562.g , tex2DNode19_g562.b));
				float2 texCoord15_g562 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g562 = tex2D( _Mask_001, ( texCoord15_g562 + float2( 0.02,0.62 ) ) );
				float3 appendResult36_g562 = (float3(tex2DNode18_g562.r , tex2DNode18_g562.g , tex2DNode18_g562.b));
				float2 texCoord41_g574 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g574 = tex2D( _Mask_001, texCoord41_g574 );
				float3 appendResult35_g574 = (float3(tex2DNode19_g574.r , tex2DNode19_g574.g , tex2DNode19_g574.b));
				float2 texCoord15_g574 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g574 = tex2D( _Mask_001, ( texCoord15_g574 + float2( 0.02,0.55 ) ) );
				float3 appendResult36_g574 = (float3(tex2DNode18_g574.r , tex2DNode18_g574.g , tex2DNode18_g574.b));
				float2 texCoord41_g578 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g578 = tex2D( _Mask_001, texCoord41_g578 );
				float3 appendResult35_g578 = (float3(tex2DNode19_g578.r , tex2DNode19_g578.g , tex2DNode19_g578.b));
				float2 texCoord15_g578 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g578 = tex2D( _Mask_001, ( texCoord15_g578 + float2( 0.02,0.47 ) ) );
				float3 appendResult36_g578 = (float3(tex2DNode18_g578.r , tex2DNode18_g578.g , tex2DNode18_g578.b));
				float2 texCoord41_g565 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g565 = tex2D( _Mask_001, texCoord41_g565 );
				float3 appendResult35_g565 = (float3(tex2DNode19_g565.r , tex2DNode19_g565.g , tex2DNode19_g565.b));
				float2 texCoord15_g565 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g565 = tex2D( _Mask_001, ( texCoord15_g565 + float2( 0.02,0.39 ) ) );
				float3 appendResult36_g565 = (float3(tex2DNode18_g565.r , tex2DNode18_g565.g , tex2DNode18_g565.b));
				float2 texCoord41_g563 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g563 = tex2D( _Mask_001, texCoord41_g563 );
				float3 appendResult35_g563 = (float3(tex2DNode19_g563.r , tex2DNode19_g563.g , tex2DNode19_g563.b));
				float2 texCoord15_g563 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g563 = tex2D( _Mask_001, ( texCoord15_g563 + float2( 0.02,0.32 ) ) );
				float3 appendResult36_g563 = (float3(tex2DNode18_g563.r , tex2DNode18_g563.g , tex2DNode18_g563.b));
				float2 texCoord41_g569 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g569 = tex2D( _Mask_001, texCoord41_g569 );
				float3 appendResult35_g569 = (float3(tex2DNode19_g569.r , tex2DNode19_g569.g , tex2DNode19_g569.b));
				float2 texCoord15_g569 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g569 = tex2D( _Mask_001, ( texCoord15_g569 + float2( 0.02,0.26 ) ) );
				float3 appendResult36_g569 = (float3(tex2DNode18_g569.r , tex2DNode18_g569.g , tex2DNode18_g569.b));
				float2 texCoord41_g579 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g579 = tex2D( _Mask_001, texCoord41_g579 );
				float3 appendResult35_g579 = (float3(tex2DNode19_g579.r , tex2DNode19_g579.g , tex2DNode19_g579.b));
				float2 texCoord15_g579 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g579 = tex2D( _Mask_001, ( texCoord15_g579 + float2( 0.02,0.15 ) ) );
				float3 appendResult36_g579 = (float3(tex2DNode18_g579.r , tex2DNode18_g579.g , tex2DNode18_g579.b));
				float2 texCoord41_g576 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g576 = tex2D( _Mask_001, texCoord41_g576 );
				float3 appendResult35_g576 = (float3(tex2DNode19_g576.r , tex2DNode19_g576.g , tex2DNode19_g576.b));
				float2 texCoord15_g576 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g576 = tex2D( _Mask_001, ( texCoord15_g576 + float2( 0.17,0.27 ) ) );
				float3 appendResult36_g576 = (float3(tex2DNode18_g576.r , tex2DNode18_g576.g , tex2DNode18_g576.b));
				float2 texCoord41_g568 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g568 = tex2D( _Mask_001, texCoord41_g568 );
				float3 appendResult35_g568 = (float3(tex2DNode19_g568.r , tex2DNode19_g568.g , tex2DNode19_g568.b));
				float2 texCoord15_g568 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g568 = tex2D( _Mask_001, ( texCoord15_g568 + float2( 0.07,0.25 ) ) );
				float3 appendResult36_g568 = (float3(tex2DNode18_g568.r , tex2DNode18_g568.g , tex2DNode18_g568.b));
				float2 texCoord41_g587 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g587 = tex2D( _Mask_001, texCoord41_g587 );
				float3 appendResult35_g587 = (float3(tex2DNode19_g587.r , tex2DNode19_g587.g , tex2DNode19_g587.b));
				float2 texCoord15_g587 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g587 = tex2D( _Mask_001, ( texCoord15_g587 + float2( 0.12,0.27 ) ) );
				float3 appendResult36_g587 = (float3(tex2DNode18_g587.r , tex2DNode18_g587.g , tex2DNode18_g587.b));
				float2 texCoord41_g585 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g585 = tex2D( _Mask_001, texCoord41_g585 );
				float3 appendResult35_g585 = (float3(tex2DNode19_g585.r , tex2DNode19_g585.g , tex2DNode19_g585.b));
				float2 texCoord15_g585 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g585 = tex2D( _Mask_001, ( texCoord15_g585 + float2( 0.09,0.315 ) ) );
				float3 appendResult36_g585 = (float3(tex2DNode18_g585.r , tex2DNode18_g585.g , tex2DNode18_g585.b));
				float2 texCoord41_g584 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g584 = tex2D( _Mask_001, texCoord41_g584 );
				float3 appendResult35_g584 = (float3(tex2DNode19_g584.r , tex2DNode19_g584.g , tex2DNode19_g584.b));
				float2 texCoord15_g584 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g584 = tex2D( _Mask_001, ( texCoord15_g584 + float2( 0.1,0.3529929 ) ) );
				float3 appendResult36_g584 = (float3(tex2DNode18_g584.r , tex2DNode18_g584.g , tex2DNode18_g584.b));
				float2 texCoord41_g583 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g583 = tex2D( _Mask_001, texCoord41_g583 );
				float3 appendResult35_g583 = (float3(tex2DNode19_g583.r , tex2DNode19_g583.g , tex2DNode19_g583.b));
				float2 texCoord15_g583 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g583 = tex2D( _Mask_001, ( texCoord15_g583 + float2( 0.07,0.4 ) ) );
				float3 appendResult36_g583 = (float3(tex2DNode18_g583.r , tex2DNode18_g583.g , tex2DNode18_g583.b));
				float2 texCoord41_g588 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g588 = tex2D( _Mask_001, texCoord41_g588 );
				float3 appendResult35_g588 = (float3(tex2DNode19_g588.r , tex2DNode19_g588.g , tex2DNode19_g588.b));
				float2 texCoord15_g588 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g588 = tex2D( _Mask_001, ( texCoord15_g588 + float2( 0.34,0.25 ) ) );
				float3 appendResult36_g588 = (float3(tex2DNode18_g588.r , tex2DNode18_g588.g , tex2DNode18_g588.b));
				float2 texCoord41_g581 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g581 = tex2D( _Mask_001, texCoord41_g581 );
				float3 appendResult35_g581 = (float3(tex2DNode19_g581.r , tex2DNode19_g581.g , tex2DNode19_g581.b));
				float2 texCoord15_g581 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g581 = tex2D( _Mask_001, ( texCoord15_g581 + float2( 0.48,0.36 ) ) );
				float3 appendResult36_g581 = (float3(tex2DNode18_g581.r , tex2DNode18_g581.g , tex2DNode18_g581.b));
				float2 texCoord41_g586 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g586 = tex2D( _Mask_001, texCoord41_g586 );
				float3 appendResult35_g586 = (float3(tex2DNode19_g586.r , tex2DNode19_g586.g , tex2DNode19_g586.b));
				float2 texCoord15_g586 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g586 = tex2D( _Mask_001, ( texCoord15_g586 + float2( 0.19,0.32 ) ) );
				float3 appendResult36_g586 = (float3(tex2DNode18_g586.r , tex2DNode18_g586.g , tex2DNode18_g586.b));
				float2 texCoord41_g589 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g589 = tex2D( _Mask_001, texCoord41_g589 );
				float3 appendResult35_g589 = (float3(tex2DNode19_g589.r , tex2DNode19_g589.g , tex2DNode19_g589.b));
				float2 texCoord15_g589 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g589 = tex2D( _Mask_001, ( texCoord15_g589 + float2( 0.5,0.61 ) ) );
				float3 appendResult36_g589 = (float3(tex2DNode18_g589.r , tex2DNode18_g589.g , tex2DNode18_g589.b));
				float2 texCoord41_g582 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g582 = tex2D( _Mask_001, texCoord41_g582 );
				float3 appendResult35_g582 = (float3(tex2DNode19_g582.r , tex2DNode19_g582.g , tex2DNode19_g582.b));
				float2 texCoord15_g582 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g582 = tex2D( _Mask_001, ( texCoord15_g582 + float2( 0.16,0.38 ) ) );
				float3 appendResult36_g582 = (float3(tex2DNode18_g582.r , tex2DNode18_g582.g , tex2DNode18_g582.b));
				float2 texCoord41_g580 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g580 = tex2D( _Mask_001, texCoord41_g580 );
				float3 appendResult35_g580 = (float3(tex2DNode19_g580.r , tex2DNode19_g580.g , tex2DNode19_g580.b));
				float2 texCoord15_g580 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g580 = tex2D( _Mask_001, ( texCoord15_g580 + float2( 0.34,0.53 ) ) );
				float3 appendResult36_g580 = (float3(tex2DNode18_g580.r , tex2DNode18_g580.g , tex2DNode18_g580.b));
				float2 texCoord41_g571 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g571 = tex2D( _Mask_001, texCoord41_g571 );
				float3 appendResult35_g571 = (float3(tex2DNode19_g571.r , tex2DNode19_g571.g , tex2DNode19_g571.b));
				float2 texCoord15_g571 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g571 = tex2D( _Mask_001, ( texCoord15_g571 + float2( 0.13,0.6 ) ) );
				float3 appendResult36_g571 = (float3(tex2DNode18_g571.r , tex2DNode18_g571.g , tex2DNode18_g571.b));
				float2 texCoord41_g573 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g573 = tex2D( _Mask_001, texCoord41_g573 );
				float3 appendResult35_g573 = (float3(tex2DNode19_g573.r , tex2DNode19_g573.g , tex2DNode19_g573.b));
				float2 texCoord15_g573 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g573 = tex2D( _Mask_001, ( texCoord15_g573 + float2( 0.19,0.54 ) ) );
				float3 appendResult36_g573 = (float3(tex2DNode18_g573.r , tex2DNode18_g573.g , tex2DNode18_g573.b));
				float2 texCoord41_g572 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g572 = tex2D( _Mask_001, texCoord41_g572 );
				float3 appendResult35_g572 = (float3(tex2DNode19_g572.r , tex2DNode19_g572.g , tex2DNode19_g572.b));
				float2 texCoord15_g572 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g572 = tex2D( _Mask_001, ( texCoord15_g572 + float2( 0.31,0.53 ) ) );
				float3 appendResult36_g572 = (float3(tex2DNode18_g572.r , tex2DNode18_g572.g , tex2DNode18_g572.b));
				float2 texCoord41_g567 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g567 = tex2D( _Mask_001, texCoord41_g567 );
				float3 appendResult35_g567 = (float3(tex2DNode19_g567.r , tex2DNode19_g567.g , tex2DNode19_g567.b));
				float2 texCoord15_g567 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g567 = tex2D( _Mask_001, ( texCoord15_g567 + float2( 0.15,0.65 ) ) );
				float3 appendResult36_g567 = (float3(tex2DNode18_g567.r , tex2DNode18_g567.g , tex2DNode18_g567.b));
				float2 texCoord41_g564 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g564 = tex2D( _Mask_001, texCoord41_g564 );
				float3 appendResult35_g564 = (float3(tex2DNode19_g564.r , tex2DNode19_g564.g , tex2DNode19_g564.b));
				float2 texCoord15_g564 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g564 = tex2D( _Mask_001, ( texCoord15_g564 + float2( 0.31,0.69 ) ) );
				float3 appendResult36_g564 = (float3(tex2DNode18_g564.r , tex2DNode18_g564.g , tex2DNode18_g564.b));
				float2 texCoord41_g575 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g575 = tex2D( _Mask_001, texCoord41_g575 );
				float3 appendResult35_g575 = (float3(tex2DNode19_g575.r , tex2DNode19_g575.g , tex2DNode19_g575.b));
				float2 texCoord15_g575 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g575 = tex2D( _Mask_001, ( texCoord15_g575 + float2( 0.07,0.68 ) ) );
				float3 appendResult36_g575 = (float3(tex2DNode18_g575.r , tex2DNode18_g575.g , tex2DNode18_g575.b));
				float2 texCoord41_g577 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g577 = tex2D( _Mask_001, texCoord41_g577 );
				float3 appendResult35_g577 = (float3(tex2DNode19_g577.r , tex2DNode19_g577.g , tex2DNode19_g577.b));
				float2 texCoord15_g577 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g577 = tex2D( _Mask_001, ( texCoord15_g577 + float2( 0.63,0.44 ) ) );
				float3 appendResult36_g577 = (float3(tex2DNode18_g577.r , tex2DNode18_g577.g , tex2DNode18_g577.b));
				float2 texCoord41_g566 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode19_g566 = tex2D( _Mask_001, texCoord41_g566 );
				float3 appendResult35_g566 = (float3(tex2DNode19_g566.r , tex2DNode19_g566.g , tex2DNode19_g566.b));
				float2 texCoord15_g566 = IN.ase_texcoord8.xy * float2( 0,0 ) + float2( 0,0 );
				float4 tex2DNode18_g566 = tex2D( _Mask_001, ( texCoord15_g566 + float2( 0.77,0.64 ) ) );
				float3 appendResult36_g566 = (float3(tex2DNode18_g566.r , tex2DNode18_g566.g , tex2DNode18_g566.b));
				float all180 = ( ( ( saturate( ( 1.0 - ( ( distance( appendResult35_g570 , appendResult36_g570 ) - 0.02 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_01 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g562 , appendResult36_g562 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_02 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g574 , appendResult36_g574 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_03 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g578 , appendResult36_g578 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_04 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g565 , appendResult36_g565 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_05 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g563 , appendResult36_g563 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_06 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g569 , appendResult36_g569 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_07 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g579 , appendResult36_g579 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_08 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g576 , appendResult36_g576 ) - 0.02 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_09 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g568 , appendResult36_g568 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_10 ) ) + ( ( saturate( ( 1.0 - ( ( distance( appendResult35_g587 , appendResult36_g587 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_11 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g585 , appendResult36_g585 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_12 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g584 , appendResult36_g584 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_13 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g583 , appendResult36_g583 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_14 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g588 , appendResult36_g588 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_15 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g581 , appendResult36_g581 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_16 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g586 , appendResult36_g586 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_17 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g589 , appendResult36_g589 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_18 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g582 , appendResult36_g582 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_19 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g580 , appendResult36_g580 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_20 ) ) + ( ( saturate( ( 1.0 - ( ( distance( appendResult35_g571 , appendResult36_g571 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_21 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g573 , appendResult36_g573 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_22 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g572 , appendResult36_g572 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_23 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g567 , appendResult36_g567 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_24 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g564 , appendResult36_g564 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_25 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g575 , appendResult36_g575 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_26 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g577 , appendResult36_g577 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_27 ) + ( saturate( ( 1.0 - ( ( distance( appendResult35_g566 , appendResult36_g566 ) - 0.05 ) / max( 0.0 , 1E-05 ) ) ) ) * _Range_28 ) ) );
				float Range_A606 = ( ( ( Diffuse_mask_R256 * 0.6 ) + ( Diffuse_mask_B258 * 0.1 ) ) * all180 );
				float4 lerpResult762 = lerp( temp_output_74_0 , ( lerpResult631 * ( 1.0 - Range_A606 ) ) , ( 1.0 - Range_A606 ));
				
				float2 uv_Normal_0_001 = IN.ase_texcoord9.xyz.xy * _Normal_0_001_ST.xy + _Normal_0_001_ST.zw;
				float3 Normal_0_001753 = UnpackNormalScale( tex2D( _Normal_0_001, uv_Normal_0_001 ), 1.0f );
				float3 lerpResult749 = lerp( Normal_0_001753 , UnpackNormalScale( tex2D( _Tattoo_1_Normal, Tattoo_1_UV_2503 ), 1.0f ) , Tattoo_1_Image511);
				float Tattoo_1_A_1515 = tex2DNode510.a;
				float Tattoo_1_A527 = saturate( ( ( Tattoo_1_A_1515 + temp_output_517_0 ) * _Tattoo_1_Visibility ) );
				float3 lerpResult649 = lerp( Normal_0_001753 , BlendNormal( UnpackNormalScale( tex2D( _Tattoo_1_Normal, Tattoo_1_UV_1504 ), 1.0f ) , lerpResult749 ) , Tattoo_1_A527);
				float3 lerpResult760 = lerp( Normal_0_001753 , UnpackNormalScale( tex2D( _Tattoo_2_Normal, Tattoo_2_UV_1514 ), 1.0f ) , Tattoo_2_A529);
				float3 lerpResult758 = lerp( Normal_0_001753 , UnpackNormalScale( tex2D( _Tattoo_2_Normal, Tattoo_2_UV_2508 ), 1.0f ) , Tattoo_2_Image519);
				float3 Normal646 = BlendNormal( lerpResult649 , BlendNormal( lerpResult760 , lerpResult758 ) );
				
				float lerpResult660 = lerp( tex2DNode545.g , tex2DNode548.g , tex2DNode548.g);
				float Tattoo_1MaskMap_M565 = lerpResult660;
				float lerpResult663 = lerp( tex2DNode551.g , tex2DNode555.g , tex2DNode555.g);
				float Tattoo_2MaskMap_M567 = lerpResult663;
				float lerpResult666 = lerp( ( Tattoo_1MaskMap_M565 * Tattoo_2MaskMap_M567 ) , _RangeMetallic , saturate( ( Range_A606 + ( Tattoo_1_A527 + Tattoo_2_A529 ) ) ));
				float Metallic678 = lerpResult666;
				
				float Tattoo_1MaskMap_S560 = ( saturate( ( tex2DNode545.r + ( tex2DNode548.r * Tattoo_1_Image511 ) ) ) *  ( Tattoo_1_A527 - 0.0 > 0.0 ? 1.0 : Tattoo_1_A527 - 0.0 <= 0.0 && Tattoo_1_A527 + 0.0 >= 0.0 ? 0.0 : 0.0 )  );
				float Tattoo_2MaskMap_S566 = ( saturate( ( tex2DNode551.r + ( tex2DNode555.r * Tattoo_2_Image519 ) ) ) *  ( Tattoo_2_A529 - 0.0 > 0.0 ? 1.0 : Tattoo_2_A529 - 0.0 <= 0.0 && Tattoo_2_A529 + 0.0 >= 0.0 ? 0.0 : 0.0 )  );
				float lerpResult687 = lerp( saturate( ( Tattoo_1MaskMap_S560 + Tattoo_2MaskMap_S566 ) ) , _RangeSmoothness , saturate( ( Range_A606 + ( Tattoo_1_A527 + Tattoo_2_A529 ) ) ));
				float Smoothness690 = lerpResult687;
				
				float3 Albedo = lerpResult762.rgb;
				float3 Normal = Normal646;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = Metallic678;
				float Smoothness = Smoothness690;
				float Occlusion = 1;
				float Alpha = ( Tattoo_1_A527 + Tattoo_2_A529 + Range_A606 );
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

	}
	
	FallBack "Hidden/Universal Render Pipeline/FallbackError"
}