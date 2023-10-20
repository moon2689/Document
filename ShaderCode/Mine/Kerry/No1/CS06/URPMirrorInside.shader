Shader "MyURP/Kerry/Lit/URPMirrorInside"
{
    Properties
    {
        _Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "AlphaTest+30"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
		    Stencil
		    {
			    Ref 1
			    Comp Equal
			    Pass Keep
			    Fail Keep
			    ZFail Keep
		    }

            HLSLPROGRAM

            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS

            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
		    float _Cutoff;


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
                half4 baseMap = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
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
                    half3 diffuse = baseMap.rgb * mainLight.color * NdotL * mainLight.shadowAttenuation * mainLight.distanceAttenuation;
                    finalLightCol = diffuse;
                }

                half4 col = half4(finalLightCol, 1);
                return col;
            }

            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
