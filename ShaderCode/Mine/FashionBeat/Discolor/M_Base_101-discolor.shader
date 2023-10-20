// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FX/M_Base_101-discolor"
{
	Properties
	{
		_Albedo("Albedo", 2D) = "white" {}
		_Mask("Mask", 2D) = "white" {}
		_Tile("Tile", 2D) = "white" {}
		_Noise_UV("Noise_UV", 2D) = "white" {}
		[Toggle(_GLOW_SWITCH_ON)] _Glow_Switch("Glow_Switch", Float) = 0
		[Toggle(_NOISE_UV_SWITCH_ON)] _Noise_UV_Switch("Noise_UV_Switch", Float) = 0
		[Toggle(_FRESNEL_NIOSE_SWITCH_ON)] _Fresnel_Niose_Switch("Fresnel_Niose_Switch", Float) = 0
		[Toggle(_MASK_1_SWITCH_ON)] _Mask_1_Switch("Mask_1-_Switch", Float) = 0
		[Toggle(_MASK_LIGHT_SWITCH_ON)] _Mask_light_Switch("Mask_light_Switch", Float) = 0
		_Tile_Intensity("Tile_Intensity", Range( 0 , 100)) = 0
		_Tile_Speed("Tile_Speed", Vector) = (0,0,0,0)
		_Albedo_Speed("Albedo_Speed", Vector) = (0,0,0,0)
		_Noise_Speed("Noise_Speed", Vector) = (0,0,0,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Fresnel_Intensity("Fresnel_Intensity", Float) = 1
		_Specular_Intensity("Specular_Intensity", Float) = 1
		_Mask_Light("Mask_Light", Float) = 1
		_Base_Light("Base_Light", Float) = 1
		[Toggle(_PANNER_ALPHA_ON)] _Panner_Alpha("Panner_Alpha", Float) = 0
		[Toggle(_MASK_ALPHA_ON)] _Mask_Alpha("Mask_Alpha", Float) = 0
		[Toggle(_OPACITY_MASK_ON)] _Opacity_Mask("Opacity_Mask", Float) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 0
		_Noise_Intensity("Noise_Intensity", Float) = 0
		_Fresnel_Color("Fresnel_Color", Color) = (0,0,0,0)
		_Base_Color("Base_Color", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1

		_DyeTex("Dye Tex", 2D) = "black" {}
		_DyeValue1("Dye Value 1", Vector) = (0, 1, 1, 0)
		_DyeValue2("Dye Value 2", Vector) = (0, 1, 1, 0)
		_DyeValue3("Dye Value 3", Vector) = (0, 1, 1, 0)
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull [_CullMode]
		ZTest LEqual
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#include "../AmericaCG.cginc"
		#pragma target 3.0
		#pragma shader_feature _GLOW_SWITCH_ON
		#pragma shader_feature _PANNER_ALPHA_ON
		#pragma shader_feature _MASK_ALPHA_ON
		#pragma shader_feature _NOISE_UV_SWITCH_ON
		#pragma shader_feature _MASK_1_SWITCH_ON
		#pragma shader_feature _FRESNEL_NIOSE_SWITCH_ON
		#pragma shader_feature _MASK_LIGHT_SWITCH_ON
		#pragma shader_feature _OPACITY_MASK_ON
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
		};

		uniform float _CullMode;
		uniform sampler2D _Albedo;
		uniform float2 _Albedo_Speed;
		uniform float _Base_Light;
		uniform float4 _Base_Color;
		uniform sampler2D _Mask;
		uniform sampler2D _Tile;
		uniform float2 _Tile_Speed;
		uniform sampler2D _Noise_UV;
		uniform float2 _Noise_Speed;
		uniform float _Noise_Intensity;
		uniform float _Tile_Intensity;
		uniform float _Fresnel_Intensity;
		uniform float4 _Fresnel_Color;
		uniform float _Mask_Light;
		uniform float _Specular_Intensity;
		uniform float _Cutoff = 0.5;

		sampler2D _DyeTex;
		float4 _DyeValue1;
		float4 _DyeValue2;
		float4 _DyeValue3;


		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 panner62 = ( _Time.x * _Albedo_Speed + i.uv_texcoord);
			float4 tex2DNode12 = tex2D( _Albedo, panner62 );
			float4 temp_cast_0 = (0.0).xxxx;
			float4 tex2DNode2 = tex2D( _Mask, i.uv_texcoord );
			#ifdef _MASK_ALPHA_ON
				float staticSwitch34 = tex2DNode2.r;
			#else
				float staticSwitch34 = tex2DNode2.a;
			#endif
			float2 panner47 = ( _Time.x * _Noise_Speed + i.uv_texcoord);
			float4 tex2DNode48 = tex2D( _Noise_UV, panner47 );
			float2 temp_cast_1 = (( tex2DNode48.r + _Noise_Intensity )).xx;
			#ifdef _NOISE_UV_SWITCH_ON
				float2 staticSwitch50 = temp_cast_1;
			#else
				float2 staticSwitch50 = i.uv_texcoord;
			#endif
			float2 panner16 = ( _Time.x * _Tile_Speed + staticSwitch50);
			float4 tex2DNode1 = tex2D( _Tile, panner16 );
			#ifdef _MASK_1_SWITCH_ON
				float staticSwitch39 = ( 1.0 - tex2DNode2.r );
			#else
				float staticSwitch39 = tex2DNode2.r;
			#endif
			#ifdef _PANNER_ALPHA_ON
				float4 staticSwitch41 = ( tex2DNode1 * staticSwitch39 );
			#else
				float4 staticSwitch41 = ( staticSwitch34 * tex2DNode1 * tex2DNode12 );
			#endif
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV21 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode21 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV21, 5.0 ) );
			float4 temp_output_22_0 = ( fresnelNode21 * _Fresnel_Intensity * _Fresnel_Color );
			#ifdef _FRESNEL_NIOSE_SWITCH_ON
				float4 staticSwitch27 = temp_output_22_0;
			#else
				float4 staticSwitch27 = ( tex2DNode1 * temp_output_22_0 );
			#endif
			#ifdef _GLOW_SWITCH_ON
				float4 staticSwitch29 = ( ( staticSwitch41 * _Tile_Intensity ) + staticSwitch27 );
			#else
				float4 staticSwitch29 = temp_cast_0;
			#endif
			#ifdef _MASK_LIGHT_SWITCH_ON
				float staticSwitch38 = ( _Mask_Light * staticSwitch39 );
			#else
				float staticSwitch38 = 0.0;
			#endif
			// dye color
			fixed4 colEmission = ((tex2DNode12 * _Base_Light * _Base_Color) + staticSwitch29 + staticSwitch38);
			fixed4 dyeCol = tex2D(_DyeTex, i.uv_texcoord);
			colEmission = ComputeFinalDyeColor(colEmission, dyeCol, _DyeValue1, _DyeValue2, _DyeValue3);

			o.Emission = colEmission.rgb;
			float3 temp_cast_3 = (_Specular_Intensity).xxx;
			o.Specular = temp_cast_3;
			o.Alpha = 1;
			#ifdef _OPACITY_MASK_ON
				float staticSwitch44 = tex2DNode12.a;
			#else
				float staticSwitch44 = tex2DNode2.a;
			#endif
			clip( staticSwitch44 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardSpecular keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputStandardSpecular o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardSpecular, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=17500
9;29;1904;1004;2440.427;799.4423;2.334944;True;True
Node;AmplifyShaderEditor.TimeNode;46;-2104.483,464.4532;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;45;-2041.64,322.6325;Float;False;Property;_Noise_Speed;Noise_Speed;12;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-2061.819,12.33182;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;47;-1860.005,321.2117;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1641.525,627.3559;Inherit;False;Property;_Noise_Intensity;Noise_Intensity;22;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;48;-1679.957,323.9569;Inherit;True;Property;_Noise_UV;Noise_UV;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;63;-1304.871,318.9461;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;61;-1270.184,-456.946;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;60;-1207.341,-598.7667;Float;False;Property;_Albedo_Speed;Albedo_Speed;11;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;17;-1163.044,336.7287;Float;False;Property;_Tile_Speed;Tile_Speed;10;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TimeNode;5;-1168,448.5;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-789.4266,38.93626;Inherit;True;Property;_Mask;Mask;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;50;-1261.632,140.5197;Inherit;False;Property;_Noise_UV_Switch;Noise_UV_Switch;5;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;16;-956.203,319.7833;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;62;-1025.706,-600.1875;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;37;-158.5513,-312.8747;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;12;-556,-625.5;Inherit;True;Property;_Albedo;Albedo;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;21;-727.7328,714.1819;Inherit;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;39;0.1041451,-469.338;Inherit;False;Property;_Mask_1_Switch;Mask_1-_Switch;7;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-757.9997,295.9;Inherit;True;Property;_Tile;Tile;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;34;-447.1905,84.91193;Inherit;False;Property;_Mask_Alpha;Mask_Alpha;19;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;64;-737.6419,1009.982;Inherit;False;Property;_Fresnel_Color;Fresnel_Color;23;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;-706.9324,902.683;Float;False;Property;_Fresnel_Intensity;Fresnel_Intensity;14;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-424.8321,719.3821;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-183.076,130.1109;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-219.7114,364.5273;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-258.5351,535.3961;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;41;54.62745,549.6302;Inherit;False;Property;_Panner_Alpha;Panner_Alpha;18;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;7;74.83936,270.093;Float;False;Property;_Tile_Intensity;Tile_Intensity;9;0;Create;True;0;0;False;0;0;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;225.1029,-544.8095;Float;False;Property;_Mask_Light;Mask_Light;16;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;27;-32.09694,805.8618;Inherit;False;Property;_Fresnel_Niose_Switch;Fresnel_Niose_Switch;6;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;331.2942,436.4953;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;30;561.1468,111.1796;Inherit;False;Constant;_Float0;Float 0;12;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;65;-127.6625,-123.0831;Inherit;False;Property;_Base_Color;Base_Color;24;0;Create;True;0;0;True;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;443.543,-515.2582;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;84.43137,-204.1172;Float;False;Property;_Base_Light;Base_Light;17;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;506.8999,545.674;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;29;696.8701,487.1373;Inherit;False;Property;_Glow_Switch;Glow_Switch;4;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;330.4117,-204.8078;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;38;709.3464,-255.689;Inherit;False;Property;_Mask_light_Switch;Mask_light_Switch;8;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;917.7849,56.08944;Float;False;Property;_Specular_Intensity;Specular_Intensity;15;0;Create;True;0;0;True;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-1341.847,493.653;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;1372.26,-163.328;Inherit;False;Property;_CullMode;CullMode;21;1;[Enum];Create;True;0;1;UnityEngine.Rendering.CullMode;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;965.4171,465.8785;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;44;42.70623,120.4162;Inherit;False;Property;_Opacity_Mask;Opacity_Mask;20;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1330.439,37.23046;Float;False;True;-1;2;;0;0;StandardSpecular;FX/M_Base_101;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;3;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;13;-1;-1;-1;0;False;0;0;True;57;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;47;0;6;0
WireConnection;47;2;45;0
WireConnection;47;1;46;1
WireConnection;48;1;47;0
WireConnection;63;0;48;1
WireConnection;63;1;59;0
WireConnection;2;1;6;0
WireConnection;50;1;6;0
WireConnection;50;0;63;0
WireConnection;16;0;50;0
WireConnection;16;2;17;0
WireConnection;16;1;5;1
WireConnection;62;0;6;0
WireConnection;62;2;60;0
WireConnection;62;1;61;1
WireConnection;37;0;2;1
WireConnection;12;1;62;0
WireConnection;39;1;2;1
WireConnection;39;0;37;0
WireConnection;1;1;16;0
WireConnection;34;1;2;4
WireConnection;34;0;2;1
WireConnection;22;0;21;0
WireConnection;22;1;23;0
WireConnection;22;2;64;0
WireConnection;3;0;34;0
WireConnection;3;1;1;0
WireConnection;3;2;12;0
WireConnection;42;0;1;0
WireConnection;42;1;39;0
WireConnection;28;0;1;0
WireConnection;28;1;22;0
WireConnection;41;1;3;0
WireConnection;41;0;42;0
WireConnection;27;1;28;0
WireConnection;27;0;22;0
WireConnection;8;0;41;0
WireConnection;8;1;7;0
WireConnection;36;0;35;0
WireConnection;36;1;39;0
WireConnection;20;0;8;0
WireConnection;20;1;27;0
WireConnection;29;1;30;0
WireConnection;29;0;20;0
WireConnection;31;0;12;0
WireConnection;31;1;32;0
WireConnection;31;2;65;0
WireConnection;38;1;30;0
WireConnection;38;0;36;0
WireConnection;58;0;48;1
WireConnection;58;1;59;0
WireConnection;33;0;31;0
WireConnection;33;1;29;0
WireConnection;33;2;38;0
WireConnection;44;1;2;4
WireConnection;44;0;12;4
WireConnection;0;2;33;0
WireConnection;0;3;19;0
WireConnection;0;10;44;0
ASEEND*/
//CHKSM=ED0A1E1C70520EEBFDA6BC9E767BB3E11F680D5B