/*
ÑÛ¾¦×é³É£º
sclera ¹®Ä¤£¬¼´ÑÛ°×
Iris ºçÄ¤
Pupil Í«¿×
Limbus ½ÇÄ¤Ôµ
Cornea ½ÇÄ¤
*/
Shader "RuoXi/URP/Lit/PBR/PBRRuoXiEye"
{
    Properties
    {
        _ScleraMap ("Sclera Map", 2D) = "white" {}
        _ScleraNormalMap ("Sclera Normal Map", 2D) = "bump" {}
        _IrisMap ("Iris Map", 2D) = "white" {}
        _IrisNormalMap ("Iris Normal Map", 2D) = "bump" {}
        _EyeDirNormal ("Eye Dir Normal Map", 2D) = "bump" {}
        _IrisHeightMap ("Iris Height Map", 2D) = "white" {}
        _SSSLut ("SSS Lut Map", 2D) = "white" {}

        _IrisRadius("Iris Radius", Range(0.15, 0.3)) = 0.136
        _PupilScale("Pupil Scale", Range(0.77, 1.3)) = 0.8
        _IOR("IOR", Range(1.1, 2)) = 1.75
        _IrisConcavityScale("IrisConcavityScale", Range(0.1, 5)) = 0
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
            // Universal Pipeline keywords
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            //#pragma multi_compile_fragment _ _SHADOWS_SOFT

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "PBRLightingEye.hlsl"

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

            TEXTURE2D(_ScleraMap); SAMPLER(sampler_ScleraMap);
            TEXTURE2D(_ScleraNormalMap); SAMPLER(sampler_ScleraNormalMap);
            TEXTURE2D(_IrisMap); SAMPLER(sampler_IrisMap);
            TEXTURE2D(_IrisNormalMap); SAMPLER(sampler_IrisNormalMap);
            TEXTURE2D(_EyeDirNormal); SAMPLER(sampler_EyeDirNormal);
            TEXTURE2D(_IrisHeightMap); SAMPLER(sampler_IrisHeightMap);
            TEXTURE2D(_SSSLut); SAMPLER(sampler_SSSLut);
            float _IrisRadius, _PupilScale, _IOR, _IrisConcavityScale;
            
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
                float3 V = GetWorldSpaceNormalizeViewDir(worldPos);

                float len = distance(i.uv, 0.5.xx);
                float irisMask = smoothstep(_IrisRadius, _IrisRadius-0.05, len);

                float4 scleraMap = SAMPLE_TEXTURE2D(_ScleraMap, sampler_ScleraMap, i.uv);
                float4 scleraNormalMap = SAMPLE_TEXTURE2D(_ScleraNormalMap, sampler_ScleraNormalMap, i.uv);
                float3 unpackNormalData_sclera = UnpackNormalScale(scleraNormalMap, 0.1);
                float3 unpackNormalData_lerp = lerp(unpackNormalData_sclera, float3(0,0,1), irisMask);
                float3 N = mul(unpackNormalData_lerp, TBN);

                // ÕÛÉä
                float3 eyeDirNormal_tangent = UnpackNormal(SAMPLE_TEXTURE2D(_EyeDirNormal, sampler_EyeDirNormal, i.uv));
                float3 worldEyeDir = mul(eyeDirNormal_tangent, TBN);
                float4 irisHeightMap = SAMPLE_TEXTURE2D(_IrisHeightMap, sampler_IrisHeightMap, i.uv);
                float4 irisHeightMap_Limbus = SAMPLE_TEXTURE2D(_IrisHeightMap, sampler_IrisHeightMap, float2(0.5+_IrisRadius,0.5));
                float irisDepth = max(irisHeightMap.r - irisHeightMap_Limbus.r, 0) * 2;
                debugCol = irisDepth.xxx;
                float irisConcavity = 0;
                float2 uv_iris;
                EyeRefraction_float(i.uv,worldNormal,V,_IOR,_IrisRadius,irisDepth,worldEyeDir,worldTangent,uv_iris,irisConcavity);
                
                // Í«¿×Ëõ·Å
                uv_iris = ScaleUVFromCircle(uv_iris, _PupilScale);

                // °µ»·limbus
                float limbus = smoothstep(_IrisRadius, _IrisRadius-0.1, len);
                float4 irisMap = SAMPLE_TEXTURE2D(_IrisMap, sampler_IrisMap, uv_iris) * limbus;

                // ºçÄ¤·¨Ïß
                float3 irisNormal_tangent = UnpackNormal(SAMPLE_TEXTURE2D(_IrisNormalMap, sampler_IrisNormalMap, uv_iris));
                float3 irisNormal_blend = BlendNormal(irisNormal_tangent, eyeDirNormal_tangent);
                float3 irisNormal = mul(irisNormal_blend, TBN);

                // ½¹É¢
                float causticWeight = irisConcavity * _IrisConcavityScale * irisMask;
                float3 causticNormal = lerp(irisNormal, -N, causticWeight);     // ²Î¿¼UE4´úÂë£ºEyeBxDF

                float3 diffuseCol = lerp(scleraMap, irisMap, irisMask).rgb;
                float3 specCol = (0.04).xxx;

                float3 pbrLighing = PBRLighting_Eye(diffuseCol, specCol, N, irisNormal, causticNormal, worldPos, irisMask, _SSSLut, sampler_SSSLut);
                
                //pbrLighing = debugCol;
                return half4(pbrLighing, 1);
            }
            ENDHLSL
        }
    }

    Fallback Off
}
