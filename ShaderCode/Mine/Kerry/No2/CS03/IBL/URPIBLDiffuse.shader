Shader "MyURP/Kerry/IBL/URPIBLDiffuse"
{
	Properties
	{
		//_MainTex ("Texture", 2D) = "white" {}
		_CubeMap("Cube Map",Cube) = "white"{}
		_Tint("Tint",Color) = (1,1,1,1)
		_Expose("Expose",Float) = 1.0
		_Rotate("Rotate",Range(0,360)) = 0
		_NormalMap("Normal Map",2D) = "bump"{}
		_NormalIntensity("Normal Intensity",Float) = 1.0
		_AOMap("AO Map",2D) = "white"{}
		_AOAdjust("AO Adjust",Range(0,1)) = 1
		_RoughnessMap("Roughness Map",2D) = "black"{}
		_RoughnessContrast("Roughness Contrast",Range(0.01,10)) = 1
		_RoughnessBrightness("Roughness Brightness",Float) = 1
		_RoughnessMin("Rough Min",Range(0,1)) = 0
		_RoughnessMax("Rough Max",Range(0,1)) = 1
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
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				float3 normal_world : TEXCOORD1;
				float3 pos_world : TEXCOORD2;
				float3 tangent_world : TEXCOORD3;
				float3 binormal_world : TEXCOORD4;
			};

			//sampler2D _MainTex;
			//float4 _MainTex_ST;
			TEXTURECUBE(_CubeMap); SAMPLER(sampler_CubeMap);
			float4 _CubeMap_HDR;
			float4 _Tint;
			float _Expose;

			TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
			float4 _NormalMap_ST;
			float _NormalIntensity;
			TEXTURE2D(_AOMap); SAMPLER(sampler_AOMap);
			float _AOAdjust;
			float _Rotate;
			float _Roughness;
			TEXTURE2D(_RoughnessMap); SAMPLER(sampler_RoughnessMap);
			float _RoughnessContrast;
			float _RoughnessBrightness;
			float _RoughnessMin;
			float _RoughnessMax;

			float3 RotateAround(float degree, float3 target)
			{
				float rad = degree * PI / 180;
				float2x2 m_rotate = float2x2(cos(rad), -sin(rad),
					sin(rad), cos(rad));
				float2 dir_rotate = mul(m_rotate, target.xz);
				target = float3(dir_rotate.x, target.y, dir_rotate.y);
				return target;
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
				o.uv = v.texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
				o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.normal_world = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.tangent_world = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
				o.binormal_world = normalize(cross(o.normal_world, o.tangent_world)) * v.tangent.w;
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				half3 normal_dir = normalize(i.normal_world);
				half3 normaldata = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,i.uv));
				normaldata.xy = normaldata.xy* _NormalIntensity;
				half3 tangent_dir = normalize(i.tangent_world);
				half3 binormal_dir = normalize(i.binormal_world);
				normal_dir = normalize(tangent_dir * normaldata.x + binormal_dir * normaldata.y + normal_dir * normaldata.z);

				half ao = SAMPLE_TEXTURE2D(_AOMap, sampler_AOMap, i.uv).r;
				ao = lerp(1.0,ao, _AOAdjust);
				
				//half3 view_dir = GetWorldSpaceNormalizeViewDir(i.pos_world);
				//half3 reflect_dir = reflect(-view_dir, normal_dir);
				//reflect_dir = RotateAround(_Rotate, reflect_dir);
				
				float roughness = SAMPLE_TEXTURE2D(_RoughnessMap, sampler_RoughnessMap, i.uv).r;
				roughness = saturate(pow(roughness, _RoughnessContrast) * _RoughnessBrightness);
				roughness = lerp(_RoughnessMin, _RoughnessMax, roughness);
				roughness = roughness * (1.7 - 0.7 * roughness);
				float mip_level = roughness * 6.0;

				half4 color_cubemap = SAMPLE_TEXTURECUBE_LOD(_CubeMap, sampler_CubeMap, normal_dir, mip_level);
				half3 env_color = DecodeHDREnvironment(color_cubemap, _CubeMap_HDR);	//确保在移动端能拿到HDR信息
				half3 final_color = env_color * ao * _Tint.rgb * _Tint.rgb * _Expose;
				//half3 final_color_linear = pow(final_color, 2.2);
				//final_color = ACES_Tonemapping(final_color_linear);
				//half3 final_color_gamma = pow(final_color, 1.0 / 2.2);
				
				final_color = env_color;

				return float4(final_color,1.0);
			}
			ENDHLSL
		}
	}
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
