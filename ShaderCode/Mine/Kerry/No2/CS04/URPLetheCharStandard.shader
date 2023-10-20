Shader "MyURP/Kerry/Lethe/URPCharStandard"
{
	Properties
	{
		[Header(BaseInfo)]
		_BaseMap ("BaseMap", 2D) = "white" {}
		_CompMask("CompMask(RM)",2D) = "white"{}
		_NormalMap("NormalMap",2D) = "bump"{}

		[Header(Specular)]
		_SpecShininess("Spec Shininess",Float) = 10
		
		[Header(SSS)]
		_SkinLUT("Skin LUT",2D) = "white"{}
		_SSSOffset("SSS Offset",Range(-1,1)) = 0
			
		[Header(IBL)]
		_EnvMap("Env Map",Cube) = "white"{}

		[HideInInspector]custom_SHAr("Custom SHAr", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHAg("Custom SHAg", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHAb("Custom SHAb", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHBr("Custom SHBr", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHBg("Custom SHBg", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHBb("Custom SHBb", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHC("Custom SHC", Vector) = (0, 0, 0, 1)
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
			TEXTURE2D(_CompMask); SAMPLER(sampler_CompMask);
			TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);

			float _SpecShininess;
			//SH
			half4 custom_SHAr;
			half4 custom_SHAg;
			half4 custom_SHAb;
			half4 custom_SHBr;
			half4 custom_SHBg;
			half4 custom_SHBb;
			half4 custom_SHC;
			//IBL
			TEXTURECUBE(_EnvMap); SAMPLER(sampler_EnvMap);
			float4 _EnvMap_HDR;
			//SSS
			TEXTURE2D(_SkinLUT); SAMPLER(sampler_SkinLUT);
			float _SSSOffset;

			float3 custom_sh(float3 normal_dir)
			{
				float4 normalForSH = float4(normal_dir, 1.0);
				//SHEvalLinearL0L1
				half3 x;
				x.r = dot(custom_SHAr, normalForSH);
				x.g = dot(custom_SHAg, normalForSH);
				x.b = dot(custom_SHAb, normalForSH);

				//SHEvalLinearL2
				half3 x1, x2;
				// 4 of the quadratic (L2) polynomials
				half4 vB = normalForSH.xyzz * normalForSH.yzzx;
				x1.r = dot(custom_SHBr, vB);
				x1.g = dot(custom_SHBg, vB);
				x1.b = dot(custom_SHBb, vB);

				// Final (5th) quadratic (L2) polynomial
				half vC = normalForSH.x*normalForSH.x - normalForSH.y*normalForSH.y;
				x2 = custom_SHC.rgb * vC;

				float3 sh = max(float3(0.0, 0.0, 0.0), (x + x1 + x2));
				sh = pow(sh, 1.0 / 2.2);
				return sh;
			}

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
				o.pos = TransformObjectToHClip(v.vertex.xyz);
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
				//albedo_color = pow(albedo_color, 2.2);
				half4 comp_mask = SAMPLE_TEXTURE2D(_CompMask, sampler_CompMask, i.uv);
				half roughness = comp_mask.r;
				half metal = comp_mask.g;
				half skin_area = 1.0 - comp_mask.b;
				half3 base_color = albedo_color.rgb * (1 - metal);//固有色
				half3 spec_color = albedo_color.rgb * metal;//高光颜色

				//Dir
				half3 view_dir = GetWorldSpaceNormalizeViewDir(i.pos_world);
				half3 normal_dir = normalize(i.normal_dir);
				half3 tangent_dir = normalize(i.tangent_dir);
				half3 binormal_dir = normalize(i.binormal_dir);
				float3x3 TBN = float3x3(tangent_dir, binormal_dir, normal_dir);
				half3 normal_data = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv));
				normal_dir = normalize(mul(normal_data, TBN));
				
				//Light Info
				Light mainLight = GetMainLight(i.shadowCoord);
				half3 light_dir = mainLight.direction;
				half3 light_col = mainLight.color;
				half atten = mainLight.shadowAttenuation;

				//Direct Diffuse直接光漫反射
				half NdotL = dot(normal_dir, light_dir);
				half half_lambert = (NdotL + 1.0) * 0.5;
				half3 common_diffuse = half_lambert * base_color * atten * light_col;
				
				half2 uv_lut = half2(NdotL * atten + _SSSOffset, 1);
				half3 lut_color = SAMPLE_TEXTURE2D(_SkinLUT, sampler_SkinLUT, uv_lut).rgb;
				//lut_color = pow(lut_color, 2.2);
				half3 sss_diffuse = lut_color * base_color * half_lambert * light_col;
				half3 direct_diffuse = lerp(common_diffuse, sss_diffuse, skin_area);

				//Direct Specular直接光镜面反射
				half3 half_dir = normalize(light_dir + view_dir);
				half NdotH = dot(normal_dir, half_dir);
				half smoothness = 1.0 - roughness;
				half shininess = lerp(1, _SpecShininess, smoothness);
				half spec_term = pow(max(0.0, NdotH), shininess);
				half3 direct_specular = spec_term * spec_color * light_col * atten;

				//Indirect Diffuse 间接光的漫反射
				float3 env_diffuse = custom_sh(normal_dir) * base_color;

				//Indirect Specular 间接光的镜面反射
				half3 reflect_dir = reflect(-view_dir, normal_dir);
				roughness = roughness * (1.7 - 0.7 * roughness);
				float mip_level = roughness * 6.0;
				half4 color_cubemap = SAMPLE_TEXTURECUBE_LOD(_EnvMap, sampler_EnvMap, reflect_dir, mip_level);
				half3 env_color = DecodeHDREnvironment(color_cubemap, _EnvMap_HDR);//确保在移动端能拿到HDR信息
				half3 env_specular = env_color * spec_color;

				float3 final_color = direct_diffuse + direct_specular + env_diffuse + env_specular;

				//final_color = ACES_Tonemapping(final_color);
				//final_color = pow(final_color, 1.0 / 2.2);

				return float4(final_color,1.0);
			}
			ENDHLSL
		}
	}

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
