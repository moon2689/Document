Shader "Unlit/BackGround"
{
    Properties
    {
        _Min("Min",Range(0,1)) = 0
        _Max("Max",Range(0,1)) = 1
        _Color1("Color1",Color) =(0,0,0,0)
        _Color2("Color2",Color) =(1,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Min,_Max;
            float4 _Color1,_Color2;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float dis = distance(uv,float2(0.5,0.5));

                float v = smoothstep(_Min,_Max,dis);
                return lerp(_Color1,_Color2,v);
            }
            ENDCG
        }
    }
}
