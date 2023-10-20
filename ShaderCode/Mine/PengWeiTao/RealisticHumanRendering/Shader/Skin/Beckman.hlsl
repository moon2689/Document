#ifndef BECKMAN
#define BECKMAN

float Fresnel_Skin(float HV)
{
    return lerp(1, 0.028, pow(1 - HV, 5));
}

//Code to Precompute the Beckmann Texture
float PHBeckmann(float ndoth, float m)
{
    float alpha = acos(ndoth);
    float ta = tan(alpha);
    float val = 1.0 / (m * m * pow(ndoth, 4.0)) * exp( - (ta * ta) / (m * m));
    return val;
}

// Render a screen-aligned quad to precompute a 512x512 texture.
float KSTextureCompute(float2 tex)
{
    // Scale the value to fit within [0,1] – invert upon lookup.
    return 0.5 * pow(PHBeckmann(tex.x, tex.y), 0.1);
}

//Computing Kelemen/Szirmay-Kalos Specular Using a Precomputed Beckmann Texture
float Specular_Beckman_Skin_Lut(float3 N, // Bumped surface normal
float3 L, // Points to light
float3 V, // Points to eye
float Roughness, // Roughness
float Intensity, // Specular brightness
in sampler2D beckmannTex)
{
    float result = 0.0;
    float ndotl = dot(N, L);
    if (ndotl > 0.0)
    {
        float3 h = L + V; // Unnormalized half-way vector
        float3 H = normalize(h);
        float ndoth = dot(N, H);
        float PH = pow(2.0 * tex2D(beckmannTex, float2(ndoth, Roughness)), 10.0);
        float F = Fresnel_Skin(dot(H, V));
        float frSpec = max(PH * F / dot(h, h), 0);
        result = ndotl * Intensity * frSpec; // BRDF * dot(N,L) * rho_s

    }
    return result;
}

float Specular_Beckman_Skin(float3 N,float3 L,float3 V,float Roughness,float Intensity)
{
    float result = 0.0;
    float ndotl = dot(N, L);
    if (ndotl > 0.0)
    {
        float3 h = L + V; // Unnormalized half-way vector
        float3 H = normalize(h);
        float ndoth = dot(N, H);
        float PH = pow(2.0 * KSTextureCompute(float2(ndoth, Roughness)), 10.0);
        float F = Fresnel_Skin(dot(H, V));
        float frSpec = max(PH * F / dot(h, h), 0);
        result = ndotl * Intensity * frSpec; // BRDF * dot(N,L) * rho_s

    }
    return result;
}
#endif