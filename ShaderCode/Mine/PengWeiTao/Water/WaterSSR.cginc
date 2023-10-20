#ifndef WATER_SSR
#define WATER_SSR

// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
// #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

// TEXTURE2D(_CameraDepthTexture);
// SAMPLER(sampler_CameraDepthTexture);

TEXTURE2D(_CameraOpaqueTexture);
SAMPLER(sampler_CameraOpaqueTexture);

float _SSRMaxSampleCount;
float _SSRSampleStep;
float _SSRIntensity;

float UVJitter(in float2 uv)
{
    return frac((52.9829189 * frac(dot(uv, float2(0.06711056, 0.00583715)))));
}

void SSRRayConvert(float3 worldPos, out float4 clipPos, out float3 screenPos)
{
    clipPos = TransformWorldToHClip(worldPos);
    float k = ((1.0) / (clipPos.w));
    screenPos.xy = ComputeScreenPos(clipPos).xy * k;
    screenPos.z = k;
}

float3 SSRRayMarch(float2 screenPos, float3 worldPos, float3 R)
{
    //开始位置
    float4 startClipPos;
    float3 startScreenPos;
    //转到ScreenPosition做RayMarching
    SSRRayConvert(worldPos, startClipPos, startScreenPos);

    float4 endClipPos;
    float3 endScreenPos;
    
    //结束位置
    SSRRayConvert(worldPos + R, endClipPos, endScreenPos);

    if (((endClipPos.w) < (startClipPos.w)))
    {
        return float3(0, 0, 0);
    }

    //步进方向
    float3 screenDir = endScreenPos - startScreenPos;

    float screenDirX = abs(screenDir.x);
    float screenDirY = abs(screenDir.y);
    
    //步进长度
    float dirMultiplier = lerp(1 / (_ScreenParams.y * screenDirY), 1 / (_ScreenParams.x * screenDirX),screenDirX > screenDirY) * _SSRSampleStep;
    screenDir *= dirMultiplier;

    half lastRayDepth = startClipPos.w;

    half sampleCount = 1 + UVJitter(screenPos.xy) * 0.1;

    float3 lastScreenMarchUVZ = startScreenPos;
    float lastDeltaDepth = 0;

    UNITY_LOOP
    for (int i = 0; i < _SSRMaxSampleCount; i++)
    {
        float3 screenMarchUVZ = startScreenPos + screenDir * sampleCount;

        if ((screenMarchUVZ.x <= 0) || (screenMarchUVZ.x >= 1) || (screenMarchUVZ.y <= 0) || (screenMarchUVZ.y >= 1))
        {
            break;
        }

        float sceneDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, screenMarchUVZ.xy), _ZBufferParams);
        half rayDepth = 1.0 / screenMarchUVZ.z;
        half deltaDepth = rayDepth - sceneDepth;

        if ((deltaDepth > 0) && (sceneDepth > startClipPos.w) && (deltaDepth < (abs(rayDepth - lastRayDepth) * 2)))
        {
            float samplePercent = saturate(lastDeltaDepth / (lastDeltaDepth - deltaDepth));
            samplePercent = lerp(samplePercent, 1, rayDepth >= _ProjectionParams.z);
            float3 hitScreenUVZ = lerp(lastScreenMarchUVZ, screenMarchUVZ, samplePercent);
            return float3(hitScreenUVZ.xy, 1);
        }

        lastRayDepth = rayDepth;
        sampleCount += 1;

        lastScreenMarchUVZ = screenMarchUVZ;
        lastDeltaDepth = deltaDepth;
    }

    float4 farClipPos;
    float3 farScreenPos;

    SSRRayConvert(worldPos + R * 100000, farClipPos, farScreenPos);

    if ((farScreenPos.x > 0) && (farScreenPos.x < 1) && (farScreenPos.y > 0) && (farScreenPos.y < 1))
    {
        float farDepth = LinearEyeDepth(
            SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, farScreenPos.xy), _ZBufferParams);

        if (farDepth > startClipPos.w)
        {
            return float3(farScreenPos.xy, 1);
        }
    }

    return float3(0, 0, 0);
}

float3 GetSSRUVZ(float2 screenUV, float2 screenPos, float3 worldPos, float3 R, float NV)
{
    float screenUVRemap = screenUV * 2 - 1;
    screenUVRemap *= screenUVRemap;
    half ssrWeight = saturate(1 - dot(screenUVRemap, screenUVRemap));
    half NoV = NV * 2.5;
    ssrWeight *= (1 - NoV * NoV);

    // if (ssrWeight > 0.005)
    {
        float3 uvz = SSRRayMarch(screenPos, worldPos, R);
        uvz.z *= ssrWeight;
        return uvz;
    }

    return float3(0, 0, 0);
}

half4 GetWaterSSR(float2 screenUV, float2 screenPos, float3 worldPos, float3 R, float NV)
{
    float3 uvz = GetSSRUVZ(screenUV, screenPos, worldPos, R, NV);
    half3 ssrColor = lerp(half3(0, 0, 0),SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, uvz.xy) * _SSRIntensity,uvz.z > 0);
    float fadeWidth = 0.15;
    float fadeMin = min(min(1.0f - screenUV.x, screenUV.x), min(1.0f - screenUV.y, screenUV.y));
    float fade = fadeMin > fadeWidth ? 1 : saturate((fadeMin / fadeWidth));
    return half4(ssrColor, uvz.z*fade);
}

#endif
