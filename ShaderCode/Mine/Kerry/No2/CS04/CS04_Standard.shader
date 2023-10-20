Shader "CS04_Standard"
{
	Properties
	{
		_BaseMap ("BaseColor Map", 2D) = "white" {}
		_CompMask("Mask(RM)",2D) = "white"{}
		_NormalMap("NormalMap",2D) = "bump"{}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal_dir : TEXCOORD1;
				float3 tangent_dir : TEXCOORD2;
				float3 binormal_dir : TEXCOORD3;
				float3 pos_world : TEXCOORD4;
				LIGHTING_COORDS(5, 6)
			};

			sampler2D _BaseMap;
			sampler2D _CompMask;
			sampler2D _NormalMap;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				o.normal_dir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.tangent_dir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
				o.binormal_dir = normalize(cross(o.normal_dir, o.tangent_dir)) * v.tangent.w;
				o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				//texture
				half4 basecolor = tex2D(_BaseMap, i.uv);
				half4 comp_mask = tex2D(_CompMask, i.uv);
				half3 normaldata = UnpackNormal(tex2D(_NormalMap, i.uv));
				
				//dir
				half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
				half3 normal_dir = normalize(i.normal_dir);
				half3 tangent_dir = normalize(i.tangent_dir);
				half3 binormal_dir = normalize(i.binormal_dir);
				float3x3 TBN = float3x3(tangent_dir, binormal_dir, normal_dir);
				normal_dir = normalize(mul(normaldata, TBN));

				//light
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float attenuation = LIGHT_ATTENUATION(i);


				//diffuse

				return basecolor;
			}
			ENDCG
		}
	}
}
