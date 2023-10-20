#include "PBRBRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

float acosFast(float inX) 
{
    float x = abs(inX);
    float res = -0.156583f * x + (0.5 * PI);
    res *= sqrt(1.0f - x);
    return (inX >= 0) ? res : PI - res;
}

// Same cost as acosFast + 1 FR
// Same error
// input [-1, 1] and output [-PI/2, PI/2]
float asinFast( float x )
{
    return (0.5 * PI) - acosFast(x);
}

float Hair_g(float B, float Theta)
{
	return exp(-0.5 * Pow2(Theta) / (B * B)) / (sqrt(2 * PI) * B);
}

float Hair_F(float CosTheta)
{
	const float n = 1.55;
	const float F0 = Pow2((1 - n) / (1 + n));
	return F0 + (1 - F0) * Pow5(1 - CosTheta);
}

// Reference: A Practical and Controllable Hair and Fur Model for Production Path Tracing.
float3 HairColorToAbsorption(float3 C, float B = 0.3f)
{
	const float b2 = B * B;
	const float b3 = B * b2;
	const float b4 = b2 * b2;
	const float b5 = B * b4;
	const float D = (5.969f - 0.215f * B + 2.532f * b2 - 10.73f * b3 + 5.574f * b4 + 0.245f * b5);
	return Pow2(log(C) / D);
}

float3 KajiyaKayDiffuseAttenuation(float3 BaseColor,float Scatter, float3 L, float3 V, half3 N, float Shadow)
{
	// Use soft Kajiya Kay diffuse attenuation
	float KajiyaDiffuse = 1 - abs(dot(N, L));

	float3 FakeNormal = normalize(V - N * dot(V, N));
	//N = normalize( DiffuseN + FakeNormal * 2 );
	N = FakeNormal;

	// Hack approximation for multiple scattering.
	float Wrap = 1;
	float NoL = saturate((dot(N, L) + Wrap) / Pow2(1 + Wrap));
	float DiffuseScatter = (1 / PI) * lerp(NoL, KajiyaDiffuse, 0.33) * Scatter;
	float Luma = Luminance(BaseColor);
	float3 ScatterTint = pow(BaseColor / Luma, 1 - Shadow);
	return sqrt(BaseColor) * DiffuseScatter * ScatterTint;
}

#define HAIR_COMPONENT_R 1
#define HAIR_COMPONENT_TT 1
#define HAIR_COMPONENT_TRT 1
#define HAIR_COMPONENT_MULTISCATTER 1

float3 HairShading(float3 BaseColor,float Specular,float Roughness,float Scatter, float3 N, float3 V, half3 L, float Shadow,float InBacklit,float Area)
{
	float ClampedRoughness = clamp(Roughness, 1/255.0f, 1.0f);
	const float Backlit	= min(InBacklit,1.0f);

	const float VoL       = dot(V,L);                                                      
	const float SinThetaL = clamp(dot(N,L), -1.f, 1.f);
	const float SinThetaV = clamp(dot(N,V), -1.f, 1.f);
	float CosThetaD = cos( 0.5 * abs( asinFast( SinThetaV ) - asinFast( SinThetaL ) ) );

	const float3 Lp = L - SinThetaL * N;
	const float3 Vp = V - SinThetaV * N;
	const float CosPhi = dot(Lp,Vp) * rsqrt( dot(Lp,Lp) * dot(Vp,Vp) + 1e-4 );
	const float CosHalfPhi = sqrt( saturate( 0.5 + 0.5 * CosPhi ) );

	float n = 1.55;
	//float n_prime = sqrt( n*n - 1 + Pow2( CosThetaD ) ) / CosThetaD;
	float n_prime = 1.19 / CosThetaD + 0.36 * CosThetaD;

	float Shift = 0.035;
	float Alpha[] =
	{
		-Shift * 2,
		Shift,
		Shift * 4,
	};	
	float B[] =
	{
		Area + Pow2(ClampedRoughness),
		Area + Pow2(ClampedRoughness) / 2,
		Area + Pow2(ClampedRoughness) * 2,
	};

	// R
	float3 S = 0;
	if (HAIR_COMPONENT_R)
	{
		const float sa = sin(Alpha[0]);
		const float ca = cos(Alpha[0]);
		float Shift = 2 * sa * (ca * CosHalfPhi * sqrt(1 - SinThetaV * SinThetaV) + sa * SinThetaV);
		float BScale = sqrt(2.0) * CosHalfPhi;
		float Mp = Hair_g(B[0] * BScale, SinThetaL + SinThetaV - Shift);
		float Np = 0.25 * CosHalfPhi;
		float Fp = Hair_F(sqrt(saturate(0.5 + 0.5 * VoL)));
		S += Mp * Np * Fp * Specular * 2 * lerp(1, Backlit, saturate(-VoL));
	}

	// TT
	if (HAIR_COMPONENT_TT)
	{
		float Mp = Hair_g( B[1], SinThetaL + SinThetaV - Alpha[1] );
		float a = 1 / n_prime;
		float h = CosHalfPhi * ( 1 + a * ( 0.6 - 0.8 * CosPhi ) );
		float f = Hair_F( CosThetaD * sqrt( saturate( 1 - h*h ) ) );
		float Fp = Pow2(1 - f);
		float3 Tp = 0;

		const float3 AbsorptionColor = HairColorToAbsorption(BaseColor);
		Tp = exp(-AbsorptionColor * 2 * abs(1 - Pow2(h * a) / CosThetaD));

		float Np = exp( -3.65 * CosPhi - 3.98 );

		S += Mp * Np * Fp * Tp * Backlit;
	}

	// TRT
	if (HAIR_COMPONENT_TRT)
	{
		float Mp = Hair_g( B[2], SinThetaL + SinThetaV - Alpha[2] );
		float f = Hair_F( CosThetaD * 0.5 );
		float Fp = Pow2(1 - f) * f;
		float3 Tp = pow( BaseColor, 0.8 / CosThetaD );
		float Np = exp( 17 * CosPhi - 16.78 );
		S += Mp * Np * Fp * Tp;
	}
	
	if(HAIR_COMPONENT_MULTISCATTER)
	{
		S += max(KajiyaKayDiffuseAttenuation(BaseColor,Scatter, L, V, N, Shadow),0.0);//一定要加Max，坑
	}

	S = -min(-S, 0.0);
	return S;
}

float3 DirectLighting_Hair(Light light, float3 diffCol, float specular, float3 worldNormal, float3 worldPos, float3 viewDir, float roughness, float scatter)
{
    float3 L = light.direction;
    float3 V = viewDir;
    float3 N = worldNormal;
	float shadow = light.shadowAttenuation * light.distanceAttenuation;
	float3 bsdfValue = HairShading(diffCol, specular, roughness, scatter, N, V, L, shadow, 0.1, 0);
	float3 lightCol = light.color * shadow;
	
	half3 lighting = bsdfValue * lightCol;
    return lighting;
}

float3 AllDirectLighting_Hair(float3 diffCol, float specular, float3 worldNormal, float3 worldPos, float3 viewDir, float roughness, float scatter)
{
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
    Light mainLight = GetMainLight(shadowCoord);

    float3 directLighting = DirectLighting_Hair(mainLight, diffCol, specular, worldNormal, worldPos, viewDir, roughness, scatter);

    #ifdef _ADDITIONAL_LIGHTS
        uint addLightCount = GetAdditionalLightsCount();
        for(uint lightIndex = 0; lightIndex < addLightCount; ++lightIndex)
        {
            Light addLight = GetAdditionalLight(lightIndex, worldPos);
            directLighting += DirectLighting_Hair(addLight, diffCol, specular, worldNormal, worldPos, viewDir, roughness, scatter);
        }
    #endif

    return directLighting;
}

float3 IndirectLighting_Hair(float3 diffCol, float specular, float3 worldNormal, float3 viewDir, float roughness, float scatter)
{
	float3 V = viewDir;
	float3 N = worldNormal;
	float3 L = normalize(V - N * dot(V, N));
	half3 diffBRDF = 2 * PI * HairShading(diffCol, specular, roughness, scatter, N, V, L, 1, 0, 0.2);
    half3 sh = SampleSH(N);
	half3 indirectDiff = diffBRDF * sh;
	return indirectDiff;
}

float3 PBRLighting_Hair(float3 diffCol, float specular, float3 worldNormal, float3 worldPos, float roughness, float scatter)
{
    float3 V = GetWorldSpaceNormalizeViewDir(worldPos);
    float3 directLighting = AllDirectLighting_Hair(diffCol, specular, worldNormal, worldPos, V, roughness, scatter);
    float3 indirectLighting = IndirectLighting_Hair(diffCol, specular, worldNormal, V, roughness, scatter);
	//indirectLighting = float3(0,0,0);
    return directLighting + indirectLighting;
}