#ifndef HAIRUE4
#define HAIRUE4

#define Pow2(v) (v*v)
#define Pow5(v) (v*v*v*v*v)

#ifndef PI
    #define PI 3.141592654
#endif

//
// Trigonometric functions
//

// max absolute error 9.0x10^-3
// Eberly's polynomial degree 1 - respect bounds
// 4 VGPR, 12 FR (8 FR, 1 QR), 1 scalar
// input [-1, 1] and output [0, PI]
float acosFast(float inX)
{
    float x = abs(inX);
    float res = -0.156583f * x + (0.5 * PI);
    res *= sqrt(1.0f - x);
    return (inX >= 0) ? res : PI - res;
}

float2 acosFast(float2 x)
{
    return float2(acosFast(x.x), acosFast(x.y));
}

float3 acosFast(float3 x)
{
    return float3(acosFast(x.x), acosFast(x.y), acosFast(x.z));
}

float4 acosFast(float4 x)
{
    return float4(acosFast(x.x), acosFast(x.y), acosFast(x.z), acosFast(x.w));
}

// Same cost as acosFast + 1 FR
// Same error
// input [-1, 1] and output [-PI/2, PI/2]
float asinFast(float x)
{
    return (0.5 * PI) - acosFast(x);
}

float2 asinFast(float2 x)
{
    return float2(asinFast(x.x), asinFast(x.y));
}

float3 asinFast(float3 x)
{
    return float3(asinFast(x.x), asinFast(x.y), asinFast(x.z));
}

float4 asinFast(float4 x)
{
    return float4(asinFast(x.x), asinFast(x.y), asinFast(x.z), asinFast(x.w));
}

// Reference: A Practical and Controllable Hair and Fur Model for Production Path Tracing.
float3 HairAbsorptionToColor(float3 A, float B = 0.3f)
{
    const float b2 = B * B;
    const float b3 = B * b2;
    const float b4 = b2 * b2;
    const float b5 = B * b4;
    const float D = (5.969f - 0.215f * B + 2.532f * b2 - 10.73f * b3 + 5.574f * b4 + 0.245f * b5);
    return exp(-sqrt(A) * D);
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

// Reference: An Energy-Conserving Hair Reflectance Model
// Adapated for [0..1] range
float3 GetHairColorFromMelanin(float InMelanin, float InRedness, float3 InDyeColor)
{
    InMelanin = saturate(InMelanin);
    InRedness = saturate(InRedness);
    const float Melanin = -log(max(1 - InMelanin, 0.0001f));
    const float Eumelanin = Melanin * (1 - InRedness);
    const float Pheomelanin = Melanin * InRedness;

    const float3 DyeAbsorption = HairColorToAbsorption(saturate(InDyeColor));
    const float3 Absorption = Eumelanin * float3(0.506f, 0.841f, 1.653f) + Pheomelanin * float3(0.343f, 0.733f, 1.924f);

    return HairAbsorptionToColor(Absorption + DyeAbsorption);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Utility functions

float Lum(float3 rgb)
{
	return dot(rgb, float3(0.0396819152, 0.458021790, 0.00609653955));
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

float3 KajiyaKayDiffuseAttenuation(float3 BaseColor, float3 L, float3 V, half3 N, float Shadow,float DiffuseIntensity)
{
    // Use soft Kajiya Kay diffuse attenuation
    float KajiyaDiffuse = 1 - abs(dot(N, L));

    float3 FakeNormal = normalize(V - N * dot(V, N));
    //N = normalize( DiffuseN + FakeNormal * 2 );
    N = FakeNormal;

    // Hack approximation for multiple scattering.
    float Wrap = 1;
    float NoL = saturate((dot(N, L) + Wrap) / Pow2(1 + Wrap));
    float DiffuseScatter = (1 / PI) * lerp(NoL, KajiyaDiffuse, 0.33) * DiffuseIntensity;
    float Luma = Lum(BaseColor);
    float3 ScatterTint = pow(abs(BaseColor / Luma), 1 - Shadow);
    return sqrt(abs(BaseColor)) * DiffuseScatter * ScatterTint;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Hair BSDF
// Approximation to HairShadingRef using concepts from the following papers:
// [Marschner et al. 2003, "Light Scattering from Human Hair Fibers"]
// [Pekelis et al. 2015, "A Data-Driven Light Scattering Model for Hair"]

float3 HairShading(float3 BaseColor,float3 Specular,float Roughness, float3 L, float3 V, half3 N, float Shadow,float InBacklit, float Area, float DiffuseIntensity)
{
    // to prevent NaN with decals
    // OR-18489 HERO: IGGY: RMB on E ability causes blinding hair effect
    // OR-17578 HERO: HAMMER: E causes blinding light on heroes with hair
    float ClampedRoughness = clamp(Roughness, 1 / 255.0f, 1.0f);

    //const float3 DiffuseN	= OctahedronToUnitVector( GBuffer.CustomData.xy * 2 - 1 );
    const float Backlit = InBacklit;

    // N is the vector parallel to hair pointing toward root

    const float VoL = dot(V, L);
    const float SinThetaL = clamp(dot(N, L), -1.f, 1.f);
    const float SinThetaV = clamp(dot(N, V), -1.f, 1.f);
    const float CosThetaD = cos(0.5 * abs(asinFast(SinThetaV) - asinFast(SinThetaL)));

    //CosThetaD = abs( CosThetaD ) < 0.01 ? 0.01 : CosThetaD;

    const float3 Lp = L - SinThetaL * N;
    const float3 Vp = V - SinThetaV * N;
    const float CosPhi = dot(Lp, Vp) * rsqrt(dot(Lp, Lp) * dot(Vp, Vp) + 1e-4);
    const float CosHalfPhi = sqrt(saturate(0.5 + 0.5 * CosPhi));
    //const float Phi = acosFast( CosPhi );

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

    float3 S = 0;
    //R
    {
        const float sa = sin(Alpha[0]);
        const float ca = cos(Alpha[0]);
        float Shift = 2 * sa * (ca * CosHalfPhi * sqrt(1 - SinThetaV * SinThetaV) + sa * SinThetaV);
        float BScale = sqrt(2.0) * CosHalfPhi;
        float Mp = Hair_g(B[0] * BScale, SinThetaL + SinThetaV - Shift);
        float Np = 0.25 * CosHalfPhi;
        float Fp = Hair_F(sqrt(saturate(0.5 + 0.5 * VoL)));
        S += Mp * Np * Fp * (Specular * 2) * lerp(1, Backlit, saturate(-VoL));
    }

    // TT
    {
        float Mp = Hair_g(B[1], SinThetaL + SinThetaV - Alpha[1]);

        float a = 1 / n_prime;
        //float h = CosHalfPhi * rsqrt( 1 + a*a - 2*a * sqrt( 0.5 - 0.5 * CosPhi ) );
        //float h = CosHalfPhi * ( ( 1 - Pow2( CosHalfPhi ) ) * a + 1 );
        float h = CosHalfPhi * (1 + a * (0.6 - 0.8 * CosPhi));
        //float h = 0.4;
        //float yi = asinFast(h);
        //float yt = asinFast(h / n_prime);

        float f = Hair_F(CosThetaD * sqrt(saturate(1 - h * h)));
        float Fp = Pow2(1 - f);
        //float3 Tp = pow( GBuffer.BaseColor, 0.5 * ( 1 + cos(2*yt) ) / CosThetaD );
        //float3 Tp = pow( GBuffer.BaseColor, 0.5 * cos(yt) / CosThetaD );
        float3 Tp = 0;
 
        // Compute absorption color which would match user intent after multiple scattering
        const float3 AbsorptionColor = HairColorToAbsorption(BaseColor);
        Tp = exp(-AbsorptionColor * 2 * abs(1 - Pow2(h * a) / CosThetaD));

        //float t = asin( 1 / n_prime );
        //float d = ( sqrt(2) - t ) / ( 1 - t );
        //float s = -0.5 * PI * (1 - 1 / n_prime) * log( 2*d - 1 - 2 * sqrt( d * (d - 1) ) );
        //float s = 0.35;
        //float Np = exp( (Phi - PI) / s ) / ( s * Pow2( 1 + exp( (Phi - PI) / s ) ) );
        //float Np = 0.71 * exp( -1.65 * Pow2(Phi - PI) );
        float Np = exp(-3.65 * CosPhi - 3.98);

        S += Mp * Np * Fp * Tp * Backlit;
    }

    // TRT
    {
        float Mp = Hair_g(B[2], SinThetaL + SinThetaV - Alpha[2]);

        //float h = 0.75;
        float f = Hair_F(CosThetaD * 0.5);
        float Fp = Pow2(1 - f) * f;
        //float3 Tp = pow( GBuffer.BaseColor, 1.6 / CosThetaD );
        float3 Tp = pow(abs(BaseColor), 0.8 / CosThetaD);

        //float s = 0.15;
        //float Np = 0.75 * exp( Phi / s ) / ( s * Pow2( 1 + exp( Phi / s ) ) );
        float Np = exp(17 * CosPhi - 16.78);

        S += Mp * Np * Fp * Tp;
    }
    
    {
        // S = EvaluateHairMultipleScattering(HairTransmittance, ClampedRoughness, S);
        // S += KajiyaKayDiffuseAttenuation(BaseColor, L, V, N, Shadow,DiffuseIntensity);
    }

    S = -min(-S, 0.0);
    return S;
}

#endif
