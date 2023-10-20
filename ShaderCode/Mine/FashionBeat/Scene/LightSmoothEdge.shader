// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "America/Scene/LightSmoothEdge"
{
	Properties
	{
		_RimMin("RimMin", Float) = 0
		_RimMax("RimMax", Float) = 0
		_FadeOffset("FadeOffset", Float) = 0
		_FadePower("FadePower", Float) = 0
		_EmissColor("EmissColor", Color) = (0,0,0,0)
		_EmissIntensity("EmissIntensity", Float) = 0
		_Expand("Expand", Float) = 0
		_Speed("Speed", Float) = 0
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		[KeywordEnum(U,V)] _Keyword0("Keyword 0", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		BlendOp Add , Add
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _KEYWORD0_U _KEYWORD0_V
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 viewDir;
		};

		uniform float _Expand;
		uniform float4 _EmissColor;
		uniform float _EmissIntensity;
		uniform sampler2D _TextureSample0;
		uniform float _Speed;
		uniform float _RimMin;
		uniform float _RimMax;
		uniform float _FadeOffset;
		uniform float _FadePower;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( ase_vertexNormal * _Expand * v.texcoord.xy.x );
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float mulTime39 = _Time.y * _Speed;
			float2 appendResult62 = (float2(i.uv_texcoord.x , ( mulTime39 + i.uv_texcoord.y )));
			float2 appendResult63 = (float2(i.uv_texcoord.y , ( mulTime39 + i.uv_texcoord.x )));
			#if defined(_KEYWORD0_U)
				float2 staticSwitch61 = appendResult62;
			#elif defined(_KEYWORD0_V)
				float2 staticSwitch61 = appendResult63;
			#else
				float2 staticSwitch61 = appendResult62;
			#endif
			o.Emission = ( _EmissColor * _EmissIntensity * tex2D( _TextureSample0, staticSwitch61 ) ).rgb;
			float3 ase_worldNormal = i.worldNormal;
			float dotResult3 = dot( ase_worldNormal , i.viewDir );
			float smoothstepResult4 = smoothstep( _RimMin , _RimMax , dotResult3);
			float temp_output_13_0 = ( 1.0 - i.uv_texcoord.x );
			float temp_output_16_0 = ( ( temp_output_13_0 - _FadeOffset ) * _FadePower );
			o.Alpha = ( smoothstepResult4 * min( temp_output_16_0 , temp_output_13_0 ) );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows vertex:vertexDataFunc 

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
			sampler3D _DitherMaskLOD;
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
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
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
				surfIN.viewDir = worldViewDir;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
-1920;0;1920;1019;1142.365;-153.2642;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;40;-3026.795,-826.3741;Float;False;Property;_Speed;Speed;10;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-1394.429,410.9037;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;39;-2801.079,-828.0198;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-2823.224,-1267.638;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;13;-986.0684,401.9297;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-566.671,582.1435;Float;False;Property;_FadeOffset;FadeOffset;3;0;Create;True;0;0;0;False;0;False;0;0.91;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-2301.321,-1394.432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-2265.421,-930.0311;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;2;-601.5,148;Float;True;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;63;-1866.812,-1000.523;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;1;-757.5,-138;Inherit;True;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;17;-490.2725,668.8154;Float;False;Property;_FadePower;FadePower;4;0;Create;True;0;0;0;False;0;False;0;-1.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;14;-295.1552,330.9333;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;62;-1870.736,-1373.319;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;61;-1378.655,-1320.953;Inherit;False;Property;_Keyword0;Keyword 0;12;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;U;V;Create;True;True;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-193.2731,-279.4799;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-212.5,-11;Float;False;Property;_RimMin;RimMin;1;0;Create;True;0;0;0;False;0;False;0;0.17;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;66.07708,440.6126;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-161.5,186;Float;False;Property;_RimMax;RimMax;2;0;Create;True;0;0;0;False;0;False;0;0.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;25;1108.939,590.6929;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;22;-3.77893,-1340.801;Float;False;Property;_EmissColor;EmissColor;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0.2608926,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;43;-282.8428,-723.1771;Inherit;True;Property;_TextureSample0;Texture Sample 0;11;0;Create;True;0;0;0;False;0;False;-1;None;cca4d0feef6055745a0b86d190e6d86d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;-94.80663,-1126.395;Float;False;Property;_EmissIntensity;EmissIntensity;8;0;Create;True;0;0;0;False;0;False;0;3.71;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;1098.939,910.6929;Float;False;Property;_Expand;Expand;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;4;155.0904,-136;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;1237.887,1081.378;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMinOpNode;19;683.7253,781.3284;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;1497.939,669.6929;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;18;433.7728,478.4407;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-37.32727,1233.413;Float;False;Property;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;0;-0.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-122.217,1014.243;Float;False;Property;_Float1;Float 1;5;0;Create;True;0;0;0;False;0;False;0;-0.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;566.841,-694.5933;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;746.3281,55.27258;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2253.107,-115.7032;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;America/Scene/LightSmoothEdge;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;0;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;39;0;40;0
WireConnection;13;0;12;1
WireConnection;64;0;39;0
WireConnection;64;1;29;2
WireConnection;65;0;39;0
WireConnection;65;1;29;1
WireConnection;63;0;29;2
WireConnection;63;1;65;0
WireConnection;14;0;13;0
WireConnection;14;1;15;0
WireConnection;62;0;29;1
WireConnection;62;1;64;0
WireConnection;61;1;62;0
WireConnection;61;0;63;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;16;0;14;0
WireConnection;16;1;17;0
WireConnection;43;1;61;0
WireConnection;4;0;3;0
WireConnection;4;1;7;0
WireConnection;4;2;8;0
WireConnection;19;0;16;0
WireConnection;19;1;13;0
WireConnection;26;0;25;0
WireConnection;26;1;27;0
WireConnection;26;2;28;1
WireConnection;18;0;16;0
WireConnection;18;1;66;0
WireConnection;18;2;67;0
WireConnection;24;0;22;0
WireConnection;24;1;23;0
WireConnection;24;2;43;0
WireConnection;20;0;4;0
WireConnection;20;1;19;0
WireConnection;0;2;24;0
WireConnection;0;9;20;0
WireConnection;0;11;26;0
ASEEND*/
//CHKSM=FEF84AC8374CCBBCA756829C0B9ED790DBDC23DA