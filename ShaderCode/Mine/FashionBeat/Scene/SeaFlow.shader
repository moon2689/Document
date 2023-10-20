// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "America/Scene/SeaFlow"
{
	Properties
	{
		_DeepRange("DeepRange", Float) = 1
		_DeepColor("DeepColor", Color) = (0,0,0,1)
		_ShallowColor("ShallowColor", Color) = (0,0,0,0.3843137)
		_FresnelColor("FresnelColor", Color) = (0,0,0,1)
		_ShoreRange("Shore Range", Float) = 1
		_FresnelPower("FresnelPower", Float) = 1
		_ShoreColor("ShoreColor", Color) = (0,0,0,1)
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_Float3("Float 3", Float) = 0
		_Speed("Speed", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		struct Input
		{
			float4 screenPos;
			float3 worldPos;
			float3 worldNormal;
			float2 uv_texcoord;
		};

		uniform float4 _DeepColor;
		uniform float4 _ShallowColor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Float3;
		uniform float _DeepRange;
		uniform float4 _FresnelColor;
		uniform float _FresnelPower;
		uniform sampler2D _TextureSample1;
		uniform float4 _Speed;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float4 _ShoreColor;
		uniform float _ShoreRange;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float blendOpSrc188 = ase_screenPos.x;
			float blendOpDest188 = ase_screenPos.y;
			float clampDepth208 = Linear01Depth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPos.xy ));
			float3 PositionFormDepth4 = (clampDepth208).xxx;
			float temp_output_7_0 = ( ( blendOpDest188 - blendOpSrc188 ) - (PositionFormDepth4).x );
			float WaterDepth8 = ( temp_output_7_0 + _Float3 );
			float clampResult15 = clamp( exp( ( -WaterDepth8 / _DeepRange ) ) , 0.0 , 1.0 );
			float4 lerpResult20 = lerp( _DeepColor , _ShallowColor , clampResult15);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV21 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode21 = ( 0.0 + 1.0 * pow( max( 1.0 - fresnelNdotV21 , 0.0001 ), _FresnelPower ) );
			float4 lerpResult22 = lerp( lerpResult20 , _FresnelColor , fresnelNode21);
			float4 WaterColor24 = lerpResult22;
			float2 uv_TexCoord114 = i.uv_texcoord + ( _Speed * _Time.y ).xy;
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor53 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ase_grabScreenPosNorm.xy);
			float4 SceneColor54 = screenColor53;
			float4 UnderWaterColor57 = SceneColor54;
			float WaterOpacity26 = ( 1.0 - (lerpResult22).a );
			float4 lerpResult60 = lerp( ( WaterColor24 * tex2D( _TextureSample1, uv_TexCoord114 ) ) , UnderWaterColor57 , WaterOpacity26);
			float3 ShoreColor40 = (( SceneColor54 * _ShoreColor )).rgb;
			float clampResult37 = clamp( exp( ( -WaterDepth8 / _ShoreRange ) ) , 0.0 , 1.0 );
			float WaterShore39 = clampResult37;
			float4 lerpResult61 = lerp( lerpResult60 , float4( ShoreColor40 , 0.0 ) , WaterShore39);
			o.Emission = lerpResult61.rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

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
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
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
				float4 screenPos : TEXCOORD3;
				float3 worldNormal : TEXCOORD4;
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
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
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
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
-273;229;2142;1007;2151.011;295.6951;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;1;-2975.146,-2775.445;Inherit;False;2790.428;1002.604;Water Depth;17;8;7;5;6;4;3;2;192;196;197;202;199;204;203;188;208;209;Water Depth;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;209;-2616.212,-2537.726;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenDepthNode;208;-2860.686,-2282.486;Inherit;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;3;-2527.027,-2337.752;Inherit;True;FLOAT3;0;1;2;3;1;0;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;4;-2267.225,-2344.751;Inherit;True;PositionFormDepth;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;6;-1934.844,-2366.746;Inherit;True;FLOAT;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;188;-1654.003,-2672.986;Inherit;True;Subtract;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;11.75;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;7;-1382.419,-2445.234;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;199;-1329.427,-2150.68;Inherit;False;Property;_Float3;Float 3;13;0;Create;True;0;0;0;False;0;False;0;10.39;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;203;-910.1742,-2425.295;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-385.3191,-2725.132;Inherit;True;WaterDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;9;-3503.627,-1422.93;Inherit;False;2403.439;1060.372;WaterColor;17;12;21;18;26;25;24;23;22;20;19;17;16;15;14;13;11;10;WaterColor;0.03066826,0,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;10;-3438.564,-891.1131;Inherit;True;8;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;11;-3202.947,-885.336;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-3228.425,-601.1682;Inherit;True;Property;_DeepRange;DeepRange;0;0;Create;True;0;0;0;False;0;False;1;3.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;13;-2995.655,-873.348;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;27;-3508.577,2551.653;Inherit;False;1970.565;587.9272;UnderWaterColor;9;57;54;53;52;51;50;49;48;47;UnderWaterColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.ExpOpNode;14;-2793.783,-871.348;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;16;-3248.331,-1372.93;Inherit;False;Property;_DeepColor;DeepColor;1;0;Create;True;0;0;0;False;0;False;0,0,0,1;0.7215686,0.7487896,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;28;-3512.307,3262.573;Inherit;False;2606.853;822.3784;Water Shore;18;46;45;44;43;42;41;40;39;38;37;36;35;34;33;32;31;30;29;Water Shore;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;17;-3255.991,-1150.93;Inherit;False;Property;_ShallowColor;ShallowColor;2;0;Create;True;0;0;0;False;0;False;0,0,0,0.3843137;0,1,0.6639676,0.3607843;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GrabScreenPosition;50;-3473.792,2620.31;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;15;-2614.528,-868.4749;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-2285.438,-702.5396;Inherit;False;Property;_FresnelPower;FresnelPower;6;0;Create;True;0;0;0;False;0;False;1;17.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;19;-2261.111,-950.014;Inherit;False;Property;_FresnelColor;FresnelColor;4;0;Create;True;0;0;0;False;0;False;0,0,0,1;0.2028302,0.433467,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;21;-2052.438,-776.5396;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-3451.722,3312.573;Inherit;True;8;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;20;-2375.847,-1111.736;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;53;-2815.544,2624.534;Inherit;False;Global;_GrabScreen0;Grab Screen 0;10;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;117;-1473.15,366.6119;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;30;-3236.306,3317.5;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;211;-1654.011,-158.6951;Inherit;False;Property;_Speed;Speed;14;0;Create;True;0;0;0;False;0;False;0,0,0,0;-1.56,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;22;-1895.084,-1087.303;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-3466.622,3549.456;Inherit;False;Property;_ShoreRange;Shore Range;5;0;Create;True;0;0;0;False;0;False;1;1.07;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-2593.647,2650.542;Inherit;False;SceneColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;23;-1766.363,-953.444;Inherit;True;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-3449.553,3613.988;Inherit;False;54;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;31;-3053.306,3320.5;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;32;-3460.562,3703.617;Inherit;False;Property;_ShoreColor;ShoreColor;7;0;Create;True;0;0;0;False;0;False;0,0,0,1;0.9056604,0.9056604,0.9056604,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;212;-1173.011,46.30487;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;114;-832.8984,-123.6528;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ExpOpNode;33;-2884.306,3323.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-3213.561,3545.618;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-1422.035,-1102.334;Inherit;False;WaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;25;-1490.133,-792.1541;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;-440.3357,-366.8003;Inherit;False;24;WaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-2052.518,2631.021;Inherit;False;UnderWaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;113;-423.7981,-87.15282;Inherit;True;Property;_TextureSample1;Texture Sample 1;10;0;Create;True;0;0;0;False;0;False;-1;None;d9533c0cab1490e41bb72cb527461d89;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;37;-2710.306,3321.5;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;36;-3010.561,3544.618;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-1291.431,-826.8489;Inherit;True;WaterOpacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-2495.306,3320.5;Inherit;False;WaterShore;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-2757.561,3551.618;Inherit;False;ShoreColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;223.5351,196.4993;Inherit;False;57;UnderWaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;239.5351,366.4994;Inherit;False;26;WaterOpacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;75.40181,-136.5527;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;60;665.9351,-151.2007;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;692.6916,25.61551;Inherit;False;40;ShoreColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;722.6916,191.6155;Inherit;False;39;WaterShore;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-3469.179,2826.991;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;2;-2962.283,-2699.351;Inherit;True;Reconstruct World Position From Depth;-1;;1;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;196;-671.1536,-2339.319;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;38;-2347.321,3452.237;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-3473.939,2939.107;Inherit;False;Property;_UnderWaterDistort;UnderWaterDistort;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;42;-2145.755,3324.743;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-3054.263,2822.306;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-2078.321,3534.237;Inherit;False;Property;_ShoreEdgeIntensity;Shore Edge Intensity;9;0;Create;True;0;0;0;False;0;False;0;0.16;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;192;-840.6233,-2030.517;Inherit;False;Property;_Float0;Float 0;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;204;-2400.884,-2700.141;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;197;-794.0801,-1857.068;Inherit;False;Property;_Float2;Float 2;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;5;-2125.335,-2735.125;Inherit;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-3198.021,2918.997;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;202;-881.4968,-2677.759;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-1588.322,3356.237;Inherit;True;ShoreEdge;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;191;-2919.473,-3266.452;Inherit;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;47;-3476.179,3046.628;Inherit;False;Constant;_Float6;Float 6;10;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-1847.322,3339.237;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-2674.756,3447.744;Inherit;False;Property;_ShoreEdgeWidth;Shore Edge Width;8;0;Create;True;0;0;0;False;0;False;0;0.23;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;61;1053.835,-38.20068;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1516.521,-136.7496;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;America/Scene/SeaFlow;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;208;0;209;0
WireConnection;3;0;208;0
WireConnection;4;0;3;0
WireConnection;6;0;4;0
WireConnection;188;0;209;1
WireConnection;188;1;209;2
WireConnection;7;0;188;0
WireConnection;7;1;6;0
WireConnection;203;0;7;0
WireConnection;203;1;199;0
WireConnection;8;0;203;0
WireConnection;11;0;10;0
WireConnection;13;0;11;0
WireConnection;13;1;12;0
WireConnection;14;0;13;0
WireConnection;15;0;14;0
WireConnection;21;3;18;0
WireConnection;20;0;16;0
WireConnection;20;1;17;0
WireConnection;20;2;15;0
WireConnection;53;0;50;0
WireConnection;30;0;29;0
WireConnection;22;0;20;0
WireConnection;22;1;19;0
WireConnection;22;2;21;0
WireConnection;54;0;53;0
WireConnection;23;0;22;0
WireConnection;31;0;30;0
WireConnection;31;1;46;0
WireConnection;212;0;211;0
WireConnection;212;1;117;0
WireConnection;114;1;212;0
WireConnection;33;0;31;0
WireConnection;34;0;45;0
WireConnection;34;1;32;0
WireConnection;24;0;22;0
WireConnection;25;0;23;0
WireConnection;57;0;54;0
WireConnection;113;1;114;0
WireConnection;37;0;33;0
WireConnection;36;0;34;0
WireConnection;26;0;25;0
WireConnection;39;0;37;0
WireConnection;40;0;36;0
WireConnection;115;0;120;0
WireConnection;115;1;113;0
WireConnection;60;0;115;0
WireConnection;60;1;63;0
WireConnection;60;2;64;0
WireConnection;196;1;192;0
WireConnection;196;2;197;0
WireConnection;38;0;35;0
WireConnection;42;0;39;0
WireConnection;42;1;38;0
WireConnection;52;0;50;0
WireConnection;52;1;51;0
WireConnection;51;0;49;0
WireConnection;51;1;48;0
WireConnection;51;2;47;0
WireConnection;202;0;7;0
WireConnection;202;1;199;0
WireConnection;44;0;43;0
WireConnection;43;0;42;0
WireConnection;43;1;41;0
WireConnection;61;0;60;0
WireConnection;61;1;65;0
WireConnection;61;2;66;0
WireConnection;0;2;61;0
ASEEND*/
//CHKSM=0F1114C73E9B35336CCF14FFD46D9236464FDC07