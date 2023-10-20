Shader "MyURP/Kerry/Lethe/URPCharHair"
{
	Properties
	{
		[Header(BaseInfo)]
		_BaseMap ("BaseMap", 2D) = "white" {}
		_BaseColor("Base Color",Color) = (1,1,1,1)
		_NormalMap("NormalMap",2D) = "bump"{}
		_RoughnessAdjust("Roughness Adjust",Range(-1,1)) = 0.0

		[Header(Specular)]
		_AnisoMap("Aniso Map",2D) = "gray"{}
		_SpecColor1("Specular Color 1", Color) = (1,1,1,1)
		_SpecShininess1("Spec Shininess 1",Range(0,1)) = 0.1
		_SpecNoise1("Spec Noise 1",float) = 1
		_SpecOffset1("Spec Offset 1",float) = 0
		
		_SpecColor2("Specular Color 2", Color) = (1,1,1,1)
		_SpecShininess2("Spec Shininess 2",Range(0,1)) = 0.1
		_SpecNoise2("Spec Noise 2",float) = 1
		_SpecOffset2("Spec Offset 2",float) = 0
			
		[Header(IBL)]
		_EnvMap("Env Map",Cube) = "white"{}
		_Expose("Expose",Float) = 1.0
		
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
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal  : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal_dir : TEXCOORD1;
				float3 pos_world : TEXCOORD2;
				float3 tangent_dir : TEXCOORD3;
				float3 binormal_dir : TEXCOORD4;
				float4 shadowCoord : TEXCOORD5;
			};

			TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
			float4 _BaseColor;
			TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);

			float _RoughnessAdjust;
			float _SpecShininess;

			//Spec
			TEXTURE2D(_AnisoMap); SAMPLER(sampler_AnisoMap);
			float4 _AnisoMap_ST;
			float4 _SpecColor1;
			float _SpecShininess1;
			float _SpecNoise1;
			float _SpecOffset1;
			float4 _SpecColor2;
			float _SpecShininess2;
			float _SpecNoise2;
			float _SpecOffset2;


			//IBL
			TEXTURECUBE(_EnvMap); SAMPLER(sampler_EnvMap);
			float4 _EnvMap_HDR;
			float _Expose;

			inline float3 ACES_Tonemapping(float3 x)
			{
				float a = 2.51f;
				float b = 0.03f;
				float c = 2.43f;
				float d = 0.59f;
				float e = 0.14f;
				float3 encode_color = saturate((x*(a*x + b)) / (x*(c*x + d) + e));
				return encode_color;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;
				o.normal_dir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.tangent_dir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
				o.binormal_dir = normalize(cross(o.normal_dir, o.tangent_dir)) * v.tangent.w;
				o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.shadowCoord = TransformWorldToShadowCoord(o.pos_world);
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				//Texture Info
				half4 albedo_color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
				//albedo_color = pow(albedo_color, 2.2) * _BaseColor;
				half3 base_color = albedo_color.rgb;
				//half3 spec_color = albedo_color.rgb;
				half roughness = saturate(_RoughnessAdjust);

				half3 normal_data = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv));
				//Dir
				half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
				half3 normal_dir = normalize(i.normal_dir);
				half3 tangent_dir = normalize(i.tangent_dir);
				half3 binormal_dir = normalize(i.binormal_dir);
				float3x3 TBN = float3x3(tangent_dir, binormal_dir, normal_dir);
				normal_dir = normalize(mul(normal_data.xyz, TBN));
				
				//Light Info
				Light light = GetMainLight();
				half3 light_dir = GetWorldSpaceNormalizeViewDir(i.pos_world);
				half atten = light.shadowAttenuation;

				//Direct Diffuse直接光漫反射
				half diff_term = max(0.0, dot(normal_dir, light_dir));
				half half_lambert = (diff_term + 1.0) * 0.5;
				//half3 common_diffuse = diff_term * base_color * atten * _LightColor0.xyz;
			
				half3 direct_diffuse = base_color;

				//Direct Specular直接光镜面反射
				half2 uv_aniso = i.uv * _AnisoMap_ST.xy + _AnisoMap_ST.zw;
				half aniso_noise = SAMPLE_TEXTURE2D(_AnisoMap, sampler_AnisoMap, uv_aniso).r - 0.5;

				half3 half_dir = normalize(light_dir + view_dir);
				half NdotH = dot(normal_dir, half_dir);
				half TdotH = dot(half_dir, tangent_dir);

				half NdotV = max(0.0, dot(view_dir, normal_dir));
				float aniso_atten = saturate(sqrt(max(0.0, half_lambert / NdotV))) * atten;
				//spec1
				float3 spec_color1 = _SpecColor1.rgb + base_color;
				float3 aniso_offset1 = normal_dir * (aniso_noise * _SpecNoise1 + _SpecOffset1);
				float3 binormal_dir1 = normalize(binormal_dir + aniso_offset1);
				float BdotH1 = dot(half_dir, binormal_dir1) / _SpecShininess1;
				float3 spec_term1 = exp(-(TdotH * TdotH + BdotH1 * BdotH1) / (1.0 + NdotH));
				float3 final_spec1 = spec_term1 * aniso_atten * spec_color1 * light.color;
				//spec
				float3 spec_color2 = _SpecColor2.rgb + base_color;
				float3 aniso_offset2 = normal_dir * (aniso_noise * _SpecNoise2 + _SpecOffset2);
				float3 binormal_dir2 = normalize(binormal_dir + aniso_offset2);
				float BdotH2 = dot(half_dir, binormal_dir2) / _SpecShininess2;
				float3 spec_term2 = exp(-(TdotH * TdotH + BdotH2 * BdotH2) / (1.0 + NdotH));
				float3 final_spec2 = spec_term2 * aniso_atten * spec_color2 * light.color;
	
				half3 direct_specular = final_spec1 + final_spec2;

				//Indirect Specular 间接光的镜面反射
				half3 reflect_dir = reflect(-view_dir, normal_dir);
				roughness = roughness * (1.7 - 0.7 * roughness);
				float mip_level = roughness * 6.0;
				half4 color_cubemap = SAMPLE_TEXTURECUBE_LOD(_EnvMap, sampler_EnvMap, reflect_dir, mip_level);
				half3 env_color = DecodeHDREnvironment(color_cubemap, _EnvMap_HDR);//确保在移动端能拿到HDR信息
				half3 env_specular = env_color * _Expose * half_lambert * aniso_noise;

				float3 final_color = direct_diffuse + direct_specular  + env_specular;

				//final_color = ACES_Tonemapping(final_color);
				//final_color = pow(final_color, 1.0 / 2.2);

				return float4(final_color,1.0);
			}
			ENDHLSL
		}
	}
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
