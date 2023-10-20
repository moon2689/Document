// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FX/M_sansuo_101-discolor"
{
	Properties
	{
		_Albedo("Albedo", 2D) = "white" {}
		_Mask("Mask", 2D) = "white" {}
		_Specular_Intensity("Specular_Intensity", Float) = 0
		[Toggle(_OPACITY_MASK_ON)] _Opacity_Mask("Opacity_Mask", Float) = 0
		_Base_Light("Base_Light", Float) = 1
		_Mask_Light("Mask_Light", Float) = 1
		[Toggle(_MASK_ALPHA_ON)] _Mask_Alpha("Mask_Alpha", Float) = 0
		_Sansuo("Sansuo", Float) = 0
		_Float0("Time", Float) = 1
		_Cutoff( "Mask Clip Value", Float ) = 0.5
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
		Cull Back
		ZTest LEqual
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "../AmericaCG.cginc"
		#pragma target 3.0
		#pragma shader_feature _MASK_ALPHA_ON
		#pragma shader_feature _OPACITY_MASK_ON
		#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Albedo;
		uniform float _Base_Light;
		uniform float _Mask_Light;
		uniform sampler2D _Mask;
		uniform float _Float0;
		uniform float _Sansuo;
		uniform float _Specular_Intensity;
		uniform float _Cutoff = 0.5;

		sampler2D _DyeTex;
		float4 _DyeValue1;
		float4 _DyeValue2;
		float4 _DyeValue3;

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float4 tex2DNode12 = tex2D( _Albedo, i.uv_texcoord );
			float4 tex2DNode2 = tex2D( _Mask, i.uv_texcoord );
			#ifdef _MASK_ALPHA_ON
				float staticSwitch34 = tex2DNode2.r;
			#else
				float staticSwitch34 = tex2DNode2.a;
			#endif
			float mulTime65 = _Time.y * _Float0;
			float4 color77 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);

			// dye color
			fixed4 colEmission = ((tex2DNode12 * _Base_Light) + (_Mask_Light * staticSwitch34 * (abs(sin(mulTime65)) * _Sansuo) * color77));
			fixed4 dyeCol = tex2D(_DyeTex, i.uv_texcoord);
			colEmission = ComputeFinalDyeColor(colEmission, dyeCol, _DyeValue1, _DyeValue2, _DyeValue3);

			o.Emission = colEmission.rgb;
			float3 temp_cast_1 = (_Specular_Intensity).xxx;
			o.Specular = temp_cast_1;
			o.Alpha = 1;
			#ifdef _OPACITY_MASK_ON
				float staticSwitch44 = tex2DNode12.a;
			#else
				float staticSwitch44 = tex2DNode2.a;
			#endif
			clip( staticSwitch44 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=17500
1693;94;1904;1004;261.894;976.5913;1.3;True;True
Node;AmplifyShaderEditor.RangedFloatNode;76;270.7835,-730.8533;Inherit;False;Property;_Float0;Time;8;0;Create;False;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;65;454.4266,-757.4037;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;66;666.9662,-761.566;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1141.183,-220.2102;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;80;824.5366,-709.9026;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-463.2644,74.37386;Inherit;True;Property;_Mask;Mask;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;69;898.4194,-577.7216;Inherit;False;Property;_Sansuo;Sansuo;7;0;Create;True;0;0;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;77;742.5657,326.4096;Inherit;False;Constant;_Color;Color;13;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;34;-9.195148,77.96467;Inherit;False;Property;_Mask_Alpha;Mask_Alpha;6;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;317.9282,-103.2221;Float;False;Property;_Base_Light;Base_Light;4;0;Create;True;0;0;True;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;689.259,-186.3797;Float;False;Property;_Mask_Light;Mask_Light;5;0;Create;True;0;0;True;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;1221.514,-726.9623;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;12;-467.5764,-353.0112;Inherit;True;Property;_Albedo;Albedo;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;359.3179,-341.9026;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;1089.857,24.37961;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;19;1322.004,141.2945;Float;False;Property;_Specular_Intensity;Specular_Intensity;2;0;Create;True;0;0;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;44;682.4826,177.5745;Inherit;False;Property;_Opacity_Mask;Opacity_Mask;3;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;1380.297,-16.91792;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1714.751,-39.00712;Float;False;True;-1;2;;0;0;StandardSpecular;FX/M_sansuo_101;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;3;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;9;-1;-1;-1;0;False;0;0;False;57;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;65;0;76;0
WireConnection;66;0;65;0
WireConnection;80;0;66;0
WireConnection;2;1;6;0
WireConnection;34;1;2;4
WireConnection;34;0;2;1
WireConnection;68;0;80;0
WireConnection;68;1;69;0
WireConnection;12;1;6;0
WireConnection;78;0;12;0
WireConnection;78;1;79;0
WireConnection;36;0;35;0
WireConnection;36;1;34;0
WireConnection;36;2;68;0
WireConnection;36;3;77;0
WireConnection;44;1;2;4
WireConnection;44;0;12;4
WireConnection;33;0;78;0
WireConnection;33;1;36;0
WireConnection;0;2;33;0
WireConnection;0;3;19;0
WireConnection;0;10;44;0
ASEEND*/
//CHKSM=423EAEFC5A657F9778EF4E0378407BF0B09E0143