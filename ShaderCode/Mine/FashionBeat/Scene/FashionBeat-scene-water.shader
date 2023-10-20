Shader "FashionBeat/Scene/Water"
{
	Properties
	{
		_Color ("Main Color", Color) = (0.5,0.5,0.5,0.5)
		
		_NoiseTex ("Distort Texture (RG)", 2D) = "white" {}
		_AlphaTex ("Alpha (A)", 2D) = "white" {}
		_WaveColor ("Wave Color", Color) = (0.5,0.5,0.5,0.5)
		_Strength  ("Strength", Vector) = (0.5, 0.5, 0.01, 0)
	}

	SubShader
	{
		Tags { "Queue"="Transparent+200" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		ZWrite Off
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			fixed4 _Color;
			
			sampler2D _NoiseTex;
			sampler2D _AlphaTex;
			float4 _AlphaTex_ST;
			fixed4 _WaveColor;
			fixed4 _Strength;
			
			
			struct appdata_t
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord: TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 uv : TEXCOORD0;
				float2 uvFlow : TEXCOORD1;
			};


			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.uv = v.texcoord;
				o.uvFlow = TRANSFORM_TEX( v.texcoord, _AlphaTex);
				return o;
			}

			fixed4 frag( v2f i ) : COLOR
			{
				//noise effect
				fixed4 offsetColor1 = tex2D(_NoiseTex, i.uvFlow + _Time.xz * _Strength.z);
				fixed4 offsetColor2 = tex2D(_NoiseTex, i.uvFlow + _Time.yx * _Strength.z);
				i.uvFlow.x += ((offsetColor1.r + offsetColor2.r) - 1) * _Strength.x;
				i.uvFlow.y += ((offsetColor1.r + offsetColor2.r) - 1) * _Strength.y;
				fixed4 alphaTex = tex2D(_AlphaTex, i.uvFlow);
				fixed4 wavCol = i.color * _WaveColor * alphaTex * _Strength.w;
				fixed4 col = _Color + wavCol;
				col.a = _Color.a;
				return col;
			}
			ENDCG
		}
	}
}
