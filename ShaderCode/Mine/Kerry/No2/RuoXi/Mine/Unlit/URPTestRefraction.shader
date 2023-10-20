Shader "RuoXi/URP/Unlit/Test Refraction"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _FrontNormalMap("Normal Map", 2D) = "bump" {}
        _IOR("IOR", Range(1.1, 2)) = 1.75
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 clipPos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 worldTangent : TEXCOORD3;
                float3 worldBinormal : TEXCOORD4;
            };

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
            TEXTURE2D(_FrontNormalMap); SAMPLER(sampler_FrontNormalMap);
            float _IOR;
            
            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.clipPos = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = normalize(mul(float4(v.normal, 0), unity_WorldToObject).xyz);
                o.worldTangent = normalize(mul(unity_ObjectToWorld, v.tangent).xyz);
                o.worldBinormal = normalize(cross(o.worldNormal, o.worldTangent) * v.tangent.w);
                return o;
            }

            float2 GetRefractionUVOffset(float3 worldNormal, float3 frontNormal, float3 worldView, float ior, float irisDepth)
            {
                // 以下公式来自于RealTimeRendering4 14.5.2 章节 Refrection
                float w = ior * dot(worldNormal, worldView);
                float k = sqrt(1 + (w - ior) * (w + ior));
                float3 refractDir = (w - k) * worldNormal - ior * worldView;

                float cosAlpha = dot(frontNormal, -refractDir);
                float refractLen = irisDepth / cosAlpha;
                float3 refractV = refractLen * refractDir;

                //float2 offset = (frontNormal * irisDepth + refractV).xy;
                //return offset;

                float2 offsetL = mul(refractV, (float3x2)unity_ObjectToWorld);
                return offsetL * float2(1, -1);

                //float2 offsetL =  mul(offsetW,(float3x2)unity_ObjectToWorld);
                //return float2(irisMask,-irisMask) * offsetL;
            }

            half4 frag (v2f i) : SV_Target
            {
                half3 debugCol;

                float3 worldPos = i.worldPos;
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldTangent = normalize(i.worldTangent);
                float3 worldBinormal = normalize(i.worldBinormal);
                float3x3 TBN = float3x3(worldTangent, worldBinormal, worldNormal);

                float4 normapMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv);
                float4 frontNormapMap = SAMPLE_TEXTURE2D(_FrontNormalMap, sampler_FrontNormalMap, i.uv);
                worldNormal = mul(UnpackNormal(normapMap), TBN);
                float3 frontNormal = mul(UnpackNormal(frontNormapMap), TBN);

                float3 viewDir = GetWorldSpaceNormalizeViewDir(worldPos);
                float2 uvOffset = GetRefractionUVOffset(worldNormal, frontNormal, viewDir, _IOR, 0.1) * float2(0.2, -0.2);
                float2 uv = i.uv + uvOffset;
                float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
                return mainTex;
            }
            ENDHLSL
        }
    }

    Fallback Off
}
