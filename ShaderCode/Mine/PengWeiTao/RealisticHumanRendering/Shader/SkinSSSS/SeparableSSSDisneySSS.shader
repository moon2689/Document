Shader "Hidden/SeparableSSSDisneySSS"
{
    Properties
    {
        _MainTex ("", 2D) = "Black" {}
    }
    CGINCLUDE
    #include "UnityCG.cginc"

    struct v2f
    {
        float4 pos : SV_POSITION;
        half2 uv : TEXCOORD0;
    };

    int _SSS_NUM_SAMPLES = 1;
    sampler2D _MainTex, _CameraDepthTexture;
    
    float4 _TexelOffsetScale;
    float4 _MainTex_TexelSize, sssColor, _MainTex_ST;
    int maxDistance = 100;
    half CloseupCompensation = 1;

    float3 Pow2(float3 x)
    { 
        return x * x; 
    }

    v2f vert(appdata_img v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord;

        return o;
    }

    half4 frag(v2f i) : SV_Target
    {
        #ifdef ENABLE_SKIN_SSSS_DEBUG_ON
            return tex2Dlod(_MainTex, float4(i.uv, 0, 0));
        #endif
        
        half2 uv = i.uv;

        float2 scale = _TexelOffsetScale.xy * _MainTex_TexelSize.xy /** BlurRadius.xx*/;
        float4 colorBlurred = 0;

        scale *= 20;
        float4 CenterColor = tex2Dlod(_MainTex, float4(uv, 0, 0));
        float centerDepth = tex2D(_CameraDepthTexture, uv).r;

        float3 weightSum = 0.0f;

        float depthVS = LinearEyeDepth(centerDepth);

        scale *= 1 / depthVS;
        half radiusCheck = scale.x + scale.y;

        if (_SSS_NUM_SAMPLES == 0) _SSS_NUM_SAMPLES = 2;

        if (radiusCheck > 0.001 && depthVS < maxDistance)
        {
            for (int k = 0; k < _SSS_NUM_SAMPLES; k++)
            {
                //float step = Pow2(2.0 * ((float)k / _SSS_NUM_SAMPLES));
                float step = (float)k / _SSS_NUM_SAMPLES;
                float2 offset = (float2)step * (float2)scale;

                float3 SampleColor = max(1e-10, sssColor.rgb);
                float3 weight = exp(-Pow2(step / SampleColor));

                weightSum += weight;

                colorBlurred.rgb += tex2Dlod(_MainTex, float4(uv + offset, 0, 0)).rgb * weight * 0.5;
                colorBlurred.rgb += tex2Dlod(_MainTex, float4(uv - offset, 0, 0)).rgb * weight * 0.5;
            }

            colorBlurred.rgb = max(1e-6, colorBlurred.rgb / weightSum);
        }
        else
            colorBlurred.rgb = CenterColor.rgb;

        return colorBlurred;
    }
    ENDCG
    SubShader
    {
        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ ENABLE_SKIN_SSSS_DEBUG_ON
            #pragma target 3.0
            ENDCG
        }
    }
    Fallback off
}