Shader "America/Dance/America-RidingDanceCircle"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}

	SubShader
	{
		Tags 
		{
			"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
			"Queue" = "Transparent"
		}
		LOD 200

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			ZWrite Off
			//ZTest Always

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = (v.uv + _MainTex_ST.zw) * _MainTex_ST.xy;
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				col *= _Color;
				col *=1.2;
				return col;
			}

			ENDCG
		}
		
	} 
}
