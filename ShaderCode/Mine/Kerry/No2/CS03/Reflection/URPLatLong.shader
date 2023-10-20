Shader "MyURP/Kerry/Unlit/URPLatLong"
{
    Properties
    {
		_PanoramaMap("Panorama Map",2D) = "white"{}
		_Tint("Tint",Color) = (1,1,1,1)
		_Expose("Expose",Float) = 1.0
		_Rotate("Rotate",Range(0,360)) = 0
		_NormalMap("Normal Map",2D) = "bump"{}
		_NormalIntensity("Normal Intensity",Float) = 1.0
		_AOMap("AO Map",2D) = "white"{}
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
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			TEXTURE2D(_PanoramaMap); SAMPLER(sampler_PanoramaMap);
			float4 _PanoramaMap_HDR;
			float4 _Tint;
			float _Expose;

			TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
			float4 _NormalMap_ST;
			float _NormalIntensity;
            TEXTURE2D(_AOMap); SAMPLER(sampler_AOMap);
			float _Rotate;

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

			float3 RotateAround(float degree, float3 target)
			{
				float rad = degree * PI / 180;		// 角度转弧度
				float2x2 m_rotate = float2x2(cos(rad), -sin(rad),
											sin(rad), cos(rad));
				float2 dir_rotate = mul(m_rotate, target.xz);
				target = float3(dir_rotate.x, target.y, dir_rotate.y);
				return target;
			}

            v2f vert(appdata v)
            {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
				o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.normal_world = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.tangent_world = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
				o.binormal_world = normalize(cross(o.normal_world, o.tangent_world)) * v.tangent.w;
				return o;
            }

            half4 frag(v2f i) : SV_TARGET
            {
				half3 normal_dir = normalize(i.normal_world);
				half3 normaldata = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv));
				normaldata.xy = normaldata.xy* _NormalIntensity;
				half3 tangent_dir = normalize(i.tangent_world);
				half3 binormal_dir = normalize(i.binormal_world);
				float3x3 TBN = float3x3(tangent_dir, binormal_dir, normal_dir);
				normal_dir = mul(normaldata, TBN);

                half4 aoCol = SAMPLE_TEXTURE2D(_AOMap, sampler_AOMap, i.uv);
				half ao = aoCol.r;
				half3 view_dir = GetWorldSpaceNormalizeViewDir(i.pos_world);
				half3 reflect_dir = reflect(-view_dir, normal_dir);

				reflect_dir = RotateAround(_Rotate, reflect_dir);
				
				float3 normalizedCoords = normalize(reflect_dir);
				float latitude = acos(normalizedCoords.y);
				float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
				float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / PI, 1.0 / PI);
				float2 uv_panorama =  float2(0.5, 1.0) - sphereCoords;

				half4 color_cubemap = SAMPLE_TEXTURE2D(_PanoramaMap, sampler_PanoramaMap, uv_panorama);
				half3 env_color = DecodeHDREnvironment(color_cubemap, _PanoramaMap_HDR);
				//half4 color_cubemap = texCUBE(_CubeMap, reflect_dir);
				//half3 env_color = DecodeHDR(color_cubemap, _CubeMap_HDR);//确保在移动端能拿到HDR信息
				half3 final_color = env_color * ao * _Tint.rgb * _Expose;
				return half4(final_color,1.0);
            }

            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
