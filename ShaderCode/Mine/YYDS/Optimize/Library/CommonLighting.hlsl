#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

half4 Lighting_BlinnPhong(half3 albedo, half3 specular, half alpha, half smoothness, half3 N, half3 V)
{
	Light mainLight = GetMainLight();
	half3 L = mainLight.direction;
	half3 H = normalize(L + V);

	half NoL = max(0, dot(N, L));
	half NoH = max(0, dot(N, H));

	half3 lightCol = mainLight.color * mainLight.shadowAttenuation * mainLight.distanceAttenuation;

	// diffuse
	half3 diffCol = albedo * lightCol * NoL;

	// spec
    half smooth = max(1, saturate(smoothness) * 50);
	half3 specCol = specular * lightCol * pow(NoH, smooth);
    
    // sh
    half3 shCol = SampleSH(N) * albedo;

    half3 lighting = half3(0, 0, 0);
	lighting += diffCol;
	lighting += specCol;
    lighting += shCol;

	half4 color = half4(lighting, alpha);
	return color;
}

half4 Lighting_HalfBlinnPhong(half3 albedo, half3 specular, half alpha, half smoothness, half3 N, half3 V)
{
	Light mainLight = GetMainLight();
	half3 L = mainLight.direction;
	half3 H = normalize(L + V);

	half NoL = dot(N, L) * 0.5 + 0.5;
	half NoH = max(0, dot(N, H));

	half3 lightCol = mainLight.color * mainLight.shadowAttenuation * mainLight.distanceAttenuation;

	// diffuse
	half3 diffCol = albedo * lightCol * NoL;

	// spec
    half smooth = max(1, saturate(smoothness) * 50);
	half3 specCol = specular * lightCol * pow(NoH, smooth);
    
    // sh
    half3 shCol = SampleSH(N) * albedo;

    half3 lighting = half3(0, 0, 0);
	lighting += diffCol;
	lighting += specCol;
    lighting += shCol;

	half4 color = half4(lighting, alpha);
	return color;
}

half4 Lighting_BlinnPhong(InputData inputData, SurfaceData surfaceData)
{
	half3 albedo = surfaceData.albedo;
	half3 specular = surfaceData.specular;
	half alpha = surfaceData.alpha;
	half smoothness = surfaceData.smoothness;
	half3 N = inputData.normalWS;
	half3 V = inputData.viewDirectionWS;

	half4 color = Lighting_BlinnPhong(albedo, specular, alpha, smoothness, N, V);
    //color.rgb = UniversalFragmentPBR(inputData, surfaceData);
	return color;
}