Shader "RuoXi/URP/Lit/PBR/PBRRuoXiClothStockings"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _BaseMap ("Base Map", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _OpacityMap ("Opacity Map", 2D) = "white" {}

        _Anisotropic ("Anisotropic", Range(-1, 1)) = 0
        _NormalScale ("Normal Scale", Range(0, 5)) = 0
        _Roughness ("Roughness", Range(0.01, 1)) = 1
        _Specular ("Specular", Range(0, 2)) = 1
        _OpacityScale ("Opacity Scale", Range(0, 1)) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent"
        }
        LOD 100

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _ADDITIONAL_LIGHTS

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "PBRLightingClothSilk.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 clipPos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 worldTangent : TEXCOORD3;
                float3 worldBinormal : TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
            TEXTURE2D(_OpacityMap); SAMPLER(sampler_OpacityMap);
            
            float4 _Color;
            float _Anisotropic, _NormalScale, _Roughness, _Specular, _OpacityScale;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.clipPos = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);

                VertexNormalInputs normalData = GetVertexNormalInputs(v.normal, v.tangent);
                o.worldNormal = normalData.normalWS;
                o.worldTangent = normalData.tangentWS;
                o.worldBinormal = normalData.bitangentWS;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                half3 debugCol;

                float3 worldPos = i.worldPos;
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldTangent = normalize(i.worldTangent);
                float3 worldBinormal = normalize(i.worldBinormal);
                float3x3 TBN = float3x3(worldTangent, worldBinormal, worldNormal);

                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv) * _Color;
                float4 opacityMap = SAMPLE_TEXTURE2D(_OpacityMap, sampler_OpacityMap, i.uv);
                float4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv);
                
                float3 tangentNormal = UnpackNormal(normalMap);
                float3 N = TransformTangentToWorld(tangentNormal, TBN);

                // 让高光受到法线图的影响
                float3 tangentT = normalize(float3(1, 0, _NormalScale * tangentNormal.x));
                float3 tangentB = normalize(float3(0, 1, _NormalScale * tangentNormal.y));
                float3 T = TransformTangentToWorld(tangentT, TBN);
                float3 B = TransformTangentToWorld(tangentB, TBN);

                float opacity = opacityMap.r * _OpacityScale;
                float3 diffuseCol = baseMap.rgb;
                float3 specCol = (_Specular * 0.04).rrr;

                float3 pbrLighing= PBRLighting_Silk(diffuseCol, specCol, worldPos, N, T, B, _Roughness, _Anisotropic);

                //debugCol = opacity.xxx;
                //pbrLighing = debugCol;
                return half4(pbrLighing, opacity);
            }
            ENDHLSL
        }

    }

    Fallback Off
}
