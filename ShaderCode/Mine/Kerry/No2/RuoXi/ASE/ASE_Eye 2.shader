Shader "Kerry/URP/PBR/ASE_Eye 2"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_IrisRadius("IrisRadius", Range(0, 0.5)) = 0
		_PupilScale("PupilScale", Range(0, 1)) = 1
		_LimbusScale("LimbusScale", Float) = 2
		_LimbusPow("LimbusPow", Float) = 5
		_IOR("IOR", Float) = 1.45
		_MidPlaneHeightMap("MidPlaneHeightMap", 2D) = "white" {}
		_EyeDirection("EyeDirection", 2D) = "bump" {}
		_SSSLUT("SSSLUT", 2D) = "white" {}
		_EnvRotation("EnvRotation", Range(0, 360)) = 0
		[Header(Sclera)]_ScleraMap("ScleraMap", 2D) = "white" {}
		_SceleraNormalMap("SceleraNormalMap", 2D) = "bump" {}
		_SceleraNormalStrength("SceleraNormalStrength", Range(0,2)) = 1
		_ScleraRoughness("ScleraRoughness", Range(0, 1)) = 0.25
		_ScleraSpecular("ScleraSpecular", Range(0, 1)) = 0.25
		[Header(Cornea)]_CorneaSpecular("CorneaSpecular", Range(0, 1)) = 0.5
		_CorneaRoughness("CorneaRoughness", Range(0, 1)) = 0.5
		[Header(Iris)]_IrisColorMap("IrisColorMap", 2D) = "white" {}
		_IrisNormalMap("IrisNormalMap", 2D) = "bump" {}
		_IrisNormalStrength("IrisNormalStrength", Range(0,2)) = 1
		_IrisConcavityScale("IrisConcavityScale", Range(0, 4)) = 0
		_IrisConcavityPow("IrisConcavityPow", Range(0.1, 0.5)) = 0
	}

	SubShader
	{
		LOD 0
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }

		Pass
		{
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			#include "../Fn_EyeLighting 1.hlsl"
			#include "../Fn_Common.hlsl"


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				float4 worldNormal : TEXCOORD3;
				float4 worldTangent : TEXCOORD4;
				float4 worldBinormal : TEXCOORD5;
				float4 screenPos : TEXCOORD6;
				float2 uv : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			CBUFFER_START(UnityPerMaterial)
			float _IrisConcavityScale;
			float _IrisNormalStrength;
			float _SceleraNormalStrength;
			float _CorneaRoughness;
			float _ScleraRoughness;
			float _CorneaSpecular;
			float _ScleraSpecular;
			float _LimbusPow;
			float _LimbusScale;
			float _PupilScale;
			float _IrisRadius;
			float _IOR;
			float _IrisConcavityPow;
			float _EnvRotation;
			CBUFFER_END
			TEXTURE2D(_ScleraMap);
			SAMPLER(sampler_ScleraMap);
			TEXTURE2D(_IrisColorMap);
			TEXTURE2D(_MidPlaneHeightMap);
			SAMPLER(sampler_MidPlaneHeightMap);
			TEXTURE2D(_EyeDirection);
			SAMPLER(sampler_EyeDirection);
			SAMPLER(sampler_IrisColorMap);
			TEXTURE2D(_SceleraNormalMap);
			SAMPLER(sampler_SceleraNormalMap);
			TEXTURE2D(_IrisNormalMap);
			SAMPLER(sampler_IrisNormalMap);
			TEXTURE2D(_SSSLUT);
			SAMPLER(sampler_linear_clamp);
			
			VertexOutput vert (VertexInput v)
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.uv = v.texcoord.xy;

				float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
				float4 positionCS = TransformWorldToHClip(positionWS);

				VertexNormalInputs normalInput = GetVertexNormalInputs(v.ase_normal, v.ase_tangent);

				o.worldNormal = float4(normalInput.normalWS, positionWS.x);
				o.worldTangent = float4(normalInput.tangentWS, positionWS.y);
				o.worldBinormal = float4(normalInput.bitangentWS, positionWS.z);	
				o.clipPos = positionCS;
				o.screenPos = ComputeScreenPos(o.clipPos);
				return o;
			}


			half4 frag (VertexOutput IN) : SV_Target
			{
				float3 debugCol;

				float3 worldNormal = normalize(IN.worldNormal.xyz);
				float3 worldTangent = IN.worldTangent.xyz;
				float3 worldBinormal = IN.worldBinormal.xyz;
				float3 worldPos = float3(IN.worldNormal.w,IN.worldTangent.w,IN.worldBinormal.w);
				float3 worldView = GetWorldSpaceNormalizeViewDir(worldPos);
				float3x3 TBN = float3x3(worldTangent, worldBinormal, worldNormal);

				// 虹膜颜色 sclera
				float4 scleraCol = SAMPLE_TEXTURE2D(_ScleraMap, sampler_ScleraMap, IN.uv);
			
				// 巩膜深度
				float4 heightMap = SAMPLE_TEXTURE2D(_MidPlaneHeightMap, sampler_MidPlaneHeightMap, IN.uv);
				float4 heightMap_limbus = SAMPLE_TEXTURE2D(_MidPlaneHeightMap, sampler_MidPlaneHeightMap, float2(_IrisRadius + 0.5, 0.5));
				float irisDepth = max(heightMap.r - heightMap_limbus.r, 0.0);

				// 计算折射
				float3 tangentEyeDir = UnpackNormal(SAMPLE_TEXTURE2D(_EyeDirection, sampler_EyeDirection, IN.uv));
				float3 worldEyeDir = mul(tangentEyeDir, TBN);
				float2 irisUV;
				float irisConcavity;
				EyeRefraction_float(IN.uv, worldNormal, worldView, _IOR, _IrisRadius, irisDepth, worldEyeDir, worldTangent, irisUV, irisConcavity);

				// 暗环 Limbus
				float2 uv_Scale;
				ScaleUVFromCircle_float(irisUV, _PupilScale, uv_Scale);
				float limbuxParam = saturate(length((uv_Scale-float2(0.5,0.5)) * _LimbusScale));
				limbuxParam = saturate(1 - pow(limbuxParam, _LimbusPow));

				// 巩膜颜色
				float4 irisCol = SAMPLE_TEXTURE2D(_IrisColorMap, sampler_IrisColorMap, uv_Scale) * limbuxParam;

				float smoothParam = 1.0 - (distance(IN.uv, float2(0.5,0.5)) - _IrisRadius + 0.045) / 0.045;
				float irisMask = smoothstep(0.0, 1.0, smoothParam);

				float3 diffCol = lerp(scleraCol, irisCol, irisMask).rgb;
				float3 specCol = (0.08 * lerp(_ScleraSpecular, _CorneaSpecular, irisMask)).xxx;
				float roughness = clamp(lerp(_ScleraRoughness, _CorneaRoughness, irisMask), 0.001, 1.0);

				// 法线
				float3 sceleraNormalMap = UnpackNormalScale(SAMPLE_TEXTURE2D(_SceleraNormalMap, sampler_SceleraNormalMap, IN.uv), _SceleraNormalStrength);
				float3 surfaceNormal = lerp(sceleraNormalMap, float3(0,0,1), irisMask);
				float3 worldNormal1 = normalize(mul(surfaceNormal, TBN));

				float3 irisNormalMap = UnpackNormalScale(SAMPLE_TEXTURE2D(_IrisNormalMap, sampler_IrisNormalMap, uv_Scale), _IrisNormalStrength);
				float3 irisNormal = normalize(mul(irisNormalMap, TBN));

				float cauticNormalWeight = pow(irisConcavity * _IrisConcavityScale, _IrisConcavityPow) * irisMask;
				float3 cauticNormal = normalize(lerp(worldEyeDir, -worldNormal1,  cauticNormalWeight));

				// pbr 光照
				float3 directLighting;
				DirectLighting_float(diffCol, specCol, roughness, worldPos, worldNormal1, worldView, irisMask, irisNormal, cauticNormal, _SSSLUT, sampler_linear_clamp, directLighting);
				
				float4 screenPos = IN.screenPos / IN.screenPos.w;
				screenPos.z = (UNITY_NEAR_CLIP_VALUE >= 0) ? screenPos.z : screenPos.z * 0.5 + 0.5;
				float occlusion;
				GetSSAO_float(screenPos.xy, occlusion);
				float3 indirectLighting;
				IndirectLighting_float(diffCol, specCol, roughness, worldPos, worldNormal1, worldView, occlusion, _EnvRotation, indirectLighting);

				float3 col = (directLighting + indirectLighting);
				//col = debugCol;
				return float4(col, 1);
				
			}

			ENDHLSL
		}
	
	}
	
	Fallback Off
	
}
