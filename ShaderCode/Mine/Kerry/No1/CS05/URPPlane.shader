Shader "MyURP/Kerry/Lit/URPPlane"
{
    Properties
    {
        _BaseMap("Base Map", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _SmoothnessMap("Smoothness Map", 2D) = "black" {}
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM

            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS

            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
            TEXTURE2D(_SmoothnessMap); SAMPLER(sampler_SmoothnessMap);

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldTangent : TEXCOORD2;
                float3 worldBinormal : TEXCOORD3;
                float3 worldPos : TEXCOORD4;
                float4 shadowCoord : TEXCOORD5;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = v.uv;
                o.worldNormal = normalize(mul(v.normal, unity_WorldToObject).xyz);
                o.worldTangent = normalize(mul(unity_ObjectToWorld, v.tangent).xyz);
                o.worldBinormal = normalize(cross(o.worldNormal, o.worldTangent) * v.tangent.w);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.shadowCoord = TransformWorldToShadowCoord(o.worldPos);
                return o;
            }

            half4 frag(v2f i) : SV_TARGET
            {
                // get info
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldTangent = normalize(i.worldTangent);
                float3 worldBinormal = normalize(i.worldBinormal);
                float3 worldPos = i.worldPos;

                // sample texture
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv * _BaseMap_ST.xy + _BaseMap_ST.zw);
                half4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv);
                half3 normalData = UnpackNormal(normalMap);

                // 法线
                float3x3 matrixTNB = float3x3(worldTangent, worldBinormal, worldNormal);
                float3 normal = mul(normalData, matrixTNB);

                // 主光源光照计算
                float4 shadowCoord = i.shadowCoord;
                float3 worldView = GetWorldSpaceNormalizeViewDir(worldPos);
                half3 finalLightCol = half3(0, 0, 0);
                {
                    Light mainLight = GetMainLight(shadowCoord);
                    // diffuse
                    float NdotL = dot(normal, mainLight.direction);
                    NdotL = saturate(NdotL * 0.5 + 0.5);
                    half3 diffuse = baseMap.rgb * mainLight.color * NdotL
                                    * mainLight.shadowAttenuation * mainLight.distanceAttenuation;

                    // specular
                    float3 halfVL = normalize(mainLight.direction + worldView);
                    float NdotH = saturate(dot(normal, halfVL));
                    float smoothness = SAMPLE_TEXTURE2D(_SmoothnessMap, sampler_SmoothnessMap, i.uv);
                    half3 specular = baseMap.rgb * mainLight.color * pow(NdotH, smoothness)
                                    * mainLight.shadowAttenuation * mainLight.distanceAttenuation;

                    finalLightCol = diffuse + specular;
                }

                half4 col = half4(finalLightCol, 1);
                return col;
            }

            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
