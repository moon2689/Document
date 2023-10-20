Shader "NewEffect/Lightmap/Unlit Alpha(CullOff)"{
  Properties{
	_Color ("Main Color", Color) = (1,1,1,1)
    _MainTex ("Base (RGB)", 2D) = "white" {}
    _Lightmap ("Lightmap (RGB)", 2D) = "black" {}
	_AlphaTex ("Alpha (A)",2D ) = "white" {}
  }

  SubShader{
    Tags {"Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True"}
    LOD 100

    Pass{
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
      	#pragma multi_compile_fog
		
		#include "UnityCG.cginc"

		struct appdata{
			float4 vertex : POSITION;
			half2 uv : TEXCOORD0;
			half2 uv1: TEXCOORD1;
		};

		struct v2f {
		float4 pos : SV_POSITION;
		half2 uv :TEXCOORD0;
		half2 uv1:TEXCOORD1;
        UNITY_FOG_COORDS(2)
		};

		sampler2D _MainTex;
		sampler2D _Lightmap;
		sampler2D _AlphaTex;
		fixed4 _Color;

		v2f vert(appdata v)
		{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		o.uv1 = v.uv1;
        UNITY_TRANSFER_FOG(o, o.pos);
		return o;
		}

		half4 frag(v2f i) : COLOR
		{

		half4 c = tex2D(_MainTex, i.uv) * _Color;
		half4 c1= tex2D(_Lightmap, i.uv1);
		fixed4 texaphla = tex2D(_AlphaTex, i.uv);
		half4 o;
		o.rgb = c.rgb * c1.rgb;
		o.a = texaphla.r * _Color.a;
        UNITY_APPLY_FOG(i.fogCoord, o);
		return o;
		}
		ENDCG
	}
  }
}