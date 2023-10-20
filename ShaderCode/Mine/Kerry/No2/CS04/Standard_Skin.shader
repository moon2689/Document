Shader "Standard_Skin" {
   Properties {
		_DiffuseMap("Diffuse Map",2D) = "white"{}
		_Color("Color",Color) = (1,1,1,1) 
		_RM("RM",2D) = "white"{}
		_RoughnessAdjust("Roughness Adjust",Range(-1,1)) = 0
		_MetallicAdjust("Metallic Adjust",Range(-1,1)) = 0
		_AOAdjust("AO Adjust",Range(0,1)) = 1
		_SpecShininess("Spec Shininess",float) = 1
		_SkinLUT("Skin LUT",2D) = "white"{}
		_SSSOffset("SSS Offset",Range(-1,1)) = 0
		_CurveOffset("Curve Offset",Range(-1,1)) = 0
		_NormalMap("NormalMap",2D) = "bump"{}
		_NormalStrength("NormalStrength",Float) = 1
		_EnvironmentMap ("Env Map", Cube) = "white" {}
		_EnvironmentIntensity("Environment Intensity",float) = 1
   }
   SubShader {
		Pass {	
		Tags { "LightMode" = "ForwardBase" }
		CGPROGRAM
 
		#pragma vertex vert  
		#pragma fragment frag 
		#pragma multi_compile_fwdbase
		#include "UnityCG.cginc"
		#include "AutoLight.cginc"
		#include "UnityStandardUtils.cginc"
		uniform float4 _LightColor0; 
		
		uniform samplerCUBE _EnvironmentMap;
		uniform float _EnvironmentIntensity;
		uniform sampler2D _NormalMap;
		float _NormalStrength;
		uniform sampler2D _DiffuseMap;
		uniform sampler2D _RM;
		sampler2D _SkinLUT;

		float _MetallicAdjust;
		float _RoughnessAdjust;
		float _AOAdjust;
		float _SpecShininess;
		float _SSSOffset;
		float _CurveOffset;
		float4 _Color;
 
		struct appdata {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float2 texcoord0 : TEXCOORD0;
			float4 tangent : TANGENT;
		};
		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
			float4 posWorld : TEXCOORD1;
			float3 normalDir : TEXCOORD2;
			float3 tangentDir : TEXCOORD3;
			float3 binormalDir : TEXCOORD4;
			LIGHTING_COORDS(5, 6)
		};
		inline float3 ACESFilm(float3 x)
		{
			float a = 2.51f;
			float b = 0.03f;
			float c = 2.43f;
			float d = 0.59f;
			float e = 0.14f;
			return saturate((x*(a*x+b))/(x*(c*x+d)+e));
		};
        v2f vert(appdata v) 
        {
			v2f o;
			float4x4 modelMatrix = unity_ObjectToWorld;

			o.posWorld = mul(modelMatrix, v.vertex);
			o.normalDir = UnityObjectToWorldNormal(v.normal);
            o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
            o.binormalDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
            o.posWorld = mul(unity_ObjectToWorld, v.vertex);
			o.uv = v.texcoord0;
			o.pos = UnityObjectToClipPos(v.vertex);
			TRANSFER_VERTEX_TO_FRAGMENT(o);
			return o;
        }
 
        float4 frag(v2f i) : COLOR
        {
			//DATA
			float4 albedo_gamma = tex2D(_DiffuseMap, i.uv);   
			float3 albedo_linear = albedo_gamma.xyz * albedo_gamma.xyz;
			float3 MRA_data = tex2D(_RM,i.uv).rgb;
			float rough = MRA_data.r;
			float roughness = lerp(0.0, 0.95, saturate(rough + _RoughnessAdjust));
			float metal = MRA_data.g;
			float metallic = saturate(metal + _MetallicAdjust);
			float skin_area = 1.0 - MRA_data.b;
			float skin_Curvature = albedo_gamma.a;
			//float occlusion = MRA_data.b;
			//float ao = lerp(1.0,occlusion,_AOAdjust);

			float4 normaldata = tex2D(_NormalMap,i.uv);
			normaldata = float4(UnpackNormal(normaldata).xyz, 1.0);		
			//normaldata.xy = normaldata.xy * _NormalStrength;
			//normaldata.z = (1.0 - dot(normaldata.xy,normaldata.xy));
			float3x3 TBN = float3x3(normalize(i.tangentDir),normalize(i.binormalDir),normalize(i.normalDir));
			float3 normalDir = normalize(mul(normaldata.xyz,TBN)); 
			float3 viewDir = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);
			
			//light info
			float3 lightDir = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz, _WorldSpaceLightPos0.w));
			float attenuation = LIGHT_ATTENUATION(i);
			//LIGHT : diffuse + specular
			float diff_laberterm = max(0.0, dot(normalDir, lightDir));
			float diff_term = diff_laberterm  * attenuation;

			float3 diffuse_color = albedo_linear * (1.0 - metallic);

			float3 diff_lut = tex2D(_SkinLUT, float2(diff_term + _SSSOffset, skin_Curvature + _CurveOffset));
			diff_lut *= diff_lut;

			float3 common_diffuse = diff_term * diffuse_color * _LightColor0.xyz;
			float3 sss_diffuse = (diff_term + 1) * 0.5 * diff_lut * diffuse_color * _LightColor0.xyz;
			float3 final_diffuse = lerp(common_diffuse, sss_diffuse,skin_area);

			float3 spec_color = lerp(0.0,albedo_linear,metallic);
			float3 H = normalize (lightDir + viewDir);
			float NdotH = max (0, dot (normalDir, H));
			float Gloss = 1.0 - roughness;
			float smoothness = lerp(1,_SpecShininess,Gloss);
			float spec = pow (NdotH, smoothness * Gloss);
			float spec_term = spec * attenuation * _LightColor0.rgb;
			float3 final_specular = spec_term * spec_color;
			//ENV
			float3 diffuse_env = ShadeSHPerPixel(normalDir, float3(0.0f, 0.0, 0.0), i.posWorld) * diffuse_color * (diff_laberterm + 1) * 0.5;
			float3 reflectDir = reflect(-viewDir,normalDir);
			float mipmap_level = roughness * 6.0;
			float3 final_env = texCUBElod(_EnvironmentMap,float4(reflectDir,mipmap_level)).rgb * _EnvironmentIntensity * spec_color * (diff_laberterm + 1) * 0.5;
			//TONEMAP
			float3 final_color = (final_diffuse + final_specular + final_env + diffuse_env * 0.5);
			//float3 final_color = final_env;
			float3 tonemap_color = ACESFilm(final_color);
			return float4(pow(tonemap_color,1/2.2),1.0);
			//return float4(final_env,1.0);
		}
		ENDCG
		}
	}
	FallBack "Diffuse"
}