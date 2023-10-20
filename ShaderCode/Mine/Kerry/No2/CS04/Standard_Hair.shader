Shader "Standard_Hair" {
   Properties {
		_DiffuseMap("Diffuse Map",2D) = "white"{}
		_Color("Color",Color) = (1,1,1,1) 
		_RoughnessAdjust("Roughness Adjust",Range(-1,1)) = 0

		_AnisoMap("Aniso Map",2D) = "gray"{}

		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_SpecShininess("Spec Shininess",float) = 1
		_AlphaY("Brush Y", float) = 1.0
		_NoiseIntensity("Noise Intensity",float) = 1
		_ShiftOffsetY("Shift Offset Y",float) = 0
		
		_SpecColor2("Specular Color 2", Color) = (1,1,1,1)
		_SpecShininess2("Spec Shininess",float) = 1
		_AlphaY2("Brush Y2", float) = 1.0
		_NoiseIntensity2("Noise Intensity2",float) = 1
		_ShiftOffsetY2("Shift Offset Y2",float) = 0

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
		//uniform float4 _LightPositionRange;
		
		uniform samplerCUBE _EnvironmentMap;
		uniform float _EnvironmentIntensity;
		uniform sampler2D _NormalMap;
		float _NormalStrength;
		uniform sampler2D _DiffuseMap;
		uniform sampler2D _RM;

		float _MetallicAdjust;
		float _RoughnessAdjust;
		float _AOAdjust;

		float4 _Color;

		float _SpecShininess;
		float _SpecShininess2;
		uniform float4 _SpecColor;
		uniform float4 _SpecColor2;
		uniform float _AlphaY;
		uniform float _AlphaY2;
		sampler2D _AnisoMap;
		float4 _AnisoMap_ST;
		float _NoiseIntensity;
		float _NoiseIntensity2;
		float _ShiftOffsetY;
		float _ShiftOffsetY2;
 
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
			float aniso = tex2D(_AnisoMap, i.uv * _AnisoMap_ST.xy + _AnisoMap_ST.zw).r;
			float4 albedo_gamma = tex2D(_DiffuseMap, i.uv);   
			float3 albedo_linear = albedo_gamma.xyz * albedo_gamma.xyz;
			float roughness = lerp(0.0, 0.95, saturate(_RoughnessAdjust));
			//float occlusion = MRA_data.b;
			//float ao = lerp(1.0,occlusion,_AOAdjust);

			float4 normaldata = tex2D(_NormalMap,i.uv);
			normaldata = float4(UnpackNormal(normaldata).xyz, 1.0);		

			float3 tangentDir = normalize(i.tangentDir);
			float3 binormalDir = normalize(i.binormalDir);
			float3x3 TBN = float3x3(tangentDir, binormalDir,normalize(i.normalDir));
			float3 normalDir = normalize(mul(normaldata.xyz,TBN)); 
			float3 viewDir = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);
			
			//light info
			float3 lightDir = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz, _WorldSpaceLightPos0.w));
			float attenuation = LIGHT_ATTENUATION(i);
			//LIGHT : diffuse + specular
			float diff_laberterm = (max(0.0, dot(normalDir, lightDir))*attenuation + 1) * 0.5;
			//float3 diff_term = diff_laberterm  * attenuation * _LightColor0.rgb;
			float3 diffuse_color = albedo_linear * _Color.xyz;
			//float3 final_diffuse = diff_term * diffuse_color;
			float3 final_diffuse = diffuse_color;

			float3 H = normalize (lightDir + viewDir);
			float NdotH = max (0, dot (normalDir, H));
			
			float aniso_offset = aniso - 0.5;

			float3 final_specular;

			float NdotV = max(0.0, dot(viewDir, normalDir));
			float TdotH = dot(H, tangentDir);

			float3 spec_color = _SpecColor.rgb + diffuse_color;
			float3 normal_shift_y1 = normalDir * (aniso_offset * _NoiseIntensity + _ShiftOffsetY);
			float3 binormalDir1 = normalize(binormalDir + normal_shift_y1);
			float BdotH1 = dot(H, binormalDir1) / _AlphaY;
			final_diffuse = attenuation * _LightColor0.rgb * spec_color * saturate(sqrt(max(0.0, diff_laberterm / NdotV)))
				* exp(-_SpecShininess * (TdotH * TdotH + BdotH1 * BdotH1) / (1.0 + NdotH));

			float3 spec_color2 = _SpecColor2.rgb + diffuse_color;
			float3 normal_shift_y2 = normalDir * (aniso_offset * _NoiseIntensity2 + _ShiftOffsetY2);
			float3 binormalDir2 = normalize(binormalDir + normal_shift_y2);
			float BdotH2 = dot(H, binormalDir2) / _AlphaY2;

			final_specular = attenuation * _LightColor0.rgb * spec_color2 * saturate(sqrt(max(0.0, diff_laberterm / NdotV)))
				* exp(-_SpecShininess2 * (TdotH * TdotH + BdotH2 * BdotH2) / (1.0 + NdotH));



			//ENV
			float3 diffuse_env = ShadeSHPerPixel(normalDir, float3(0.0f, 0.0, 0.0), i.posWorld) * diffuse_color * diff_laberterm * aniso;
			float3 reflectDir = reflect(-viewDir,normalDir);
			float mipmap_level = roughness * 6.0;
			float3 env_color = texCUBElod(_EnvironmentMap, float4(reflectDir, mipmap_level)).rgb;
			float env_lumin = dot(env_color, half3(0.2126729f, 0.7151522f, 0.0721750f));
			float3 final_env = env_color * _EnvironmentIntensity * diff_laberterm * aniso;
			//TONEMAP
			float3 final_color = (diffuse_color + final_diffuse + final_specular + final_env);
			//float3 final_color = final_env;
			float3 tonemap_color = ACESFilm(final_color);
			return float4(pow(tonemap_color,1/2.2),1.0);
			//return float4(final_diffuse + final_specular,1.0);
		}
		ENDCG
		}
	}
	FallBack "Diffuse"
}