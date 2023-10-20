Shader "Unlit/RainDrop"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Size("Size", Range(0, 100)) = 1.0
        _T("Time", Float) = 1.0
        _Distortion("Distortion", Float) = -5
        _Blur("Blur", Range(0, 1)) = 0.0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
            half _Size;
            half _T;
            half _Distortion;
            half _Blur;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // 求伪随机数
            half N21(half2 p)
            {
                p = frac(p * half2(123.34, 345.45));
                p += dot(p, p + 34.345);
                return frac(p.x + p.y);
            }

            half3 layer(half2 UV, half T)
            {
                half t = fmod(_Time.y + T, 3600);
                half aspect = half2(2, 1);
                half2 uv = UV * _Size * aspect;
                uv.y += t * 0.25;
                half2 gv = frac(uv) - 0.5; //-0.5，调整原点为中间
                half2 id = floor(uv);
                half n = N21(id); // 0 1
                t += n * 6.2831; //2PI

                half w = UV.y * 10;
                half x = (n - 0.5) * 0.8;
                x += (0.4 - abs(x)) * sin(3 * w) * pow(sin(w), 6) * 0.45;
                half y = -sin(t + sin(t + sin(t) * 0.5)) * 0.45;
                y -= (gv.x - x) * (gv.x - x);
                half2 dropPos = (gv - half2(x, y)) / aspect; //- half2(x,y) 为了移动
                half drop = smoothstep(0.05, 0.03, length(dropPos));

                half2 trailPos = (gv - half2(x, t * 0.25)) / aspect; //- half2(x,y) 为了移动
                trailPos.y = (frac(trailPos.y * 8) - 0.5) / 8;
                half trail = smoothstep(0.03, 0.01, length(trailPos));
                half fogTrail = smoothstep(-0.05, 0.05, dropPos.y); // 拖尾小水滴慢慢被拖掉了
                fogTrail *= smoothstep(0.5, y, gv.y); // 拖尾小水滴渐变消失
                fogTrail *= smoothstep(0.05, 0.04, abs(dropPos.x));
                trail *= fogTrail;
                //col += fogTrail * 0.5;
                //col += trail;
                //col += drop;
                //if(gv.x > 0.48 || gv.y > 0.49) col = half4(1.0, 0, 0, 1.0); // 辅助线
                half2 offset = drop * dropPos + trail * trailPos;
                return half3(offset, fogTrail);
            }

            half4 frag(v2f i) : SV_Target
            {
                half3 drops = layer(i.uv, _T);
                drops += layer(i.uv * 1.25 + 7.52, _T);
                return float4(drops.xy,0,0);
                drops += layer(i.uv * 1.35 + 1.54, _T);
                drops += layer(i.uv * 1.57 - 7.52, _T);
                half blur = _Blur * 7 * (1 - drops.z);
                half4 col = tex2Dlod(_MainTex, half4(i.uv + drops.xy * _Distortion, 0, blur));
                return col;
            }
            ENDCG
        }
    }

}