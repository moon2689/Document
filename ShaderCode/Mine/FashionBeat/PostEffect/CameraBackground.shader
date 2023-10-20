Shader "FashionBeat/UI/Post Effect/Camera Background"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _BackgroundTex("Background Texture", 2D) = "black" {}
    }

    SubShader
    {
        Pass
        {
            ZTest Always
            ZWrite Off
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            sampler2D _BackgroundTex;

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
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed4 texBg = tex2D(_BackgroundTex, i.uv);

				float weight = max(tex.a, tex.r);
				weight = max(weight, tex.g);
				weight = max(weight, tex.b);
				fixed4 col = lerp(texBg, tex, weight);
				col.a = max(weight, texBg.a);
				return col;
            }

            ENDCG
        }
    }

    Fallback Off
}