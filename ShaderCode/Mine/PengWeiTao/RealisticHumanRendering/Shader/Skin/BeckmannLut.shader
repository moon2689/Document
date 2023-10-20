Shader "Unlit/BeckmannLut"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float Fresnel_Skin(float HV)
            {
                return lerp(1,0.028,pow(1-HV,5));
            }
            
            //Code to Precompute the Beckmann Texture
            float PHBeckmann( float ndoth, float m ) 
            {   
                float alpha = acos( ndoth );   
                float ta = tan( alpha );   
                float val = 1.0/(m*m*pow(ndoth,4.0))*exp(-(ta*ta)/(m*m));   
                return val; 
            }
            
            // Render a screen-aligned quad to precompute a 512x512 texture.    
            float KSTextureCompute(float2 tex)
            {   
                // Scale the value to fit within [0,1] – invert upon lookup.
                return 0.5 * pow( PHBeckmann( tex.x, tex.y ), 0.1 ); 
            }   
        
            //Computing Kelemen/Szirmay-Kalos Specular Using a Precomputed Beckmann Texture
            float KS_Skin_Specular( float3 N, // Bumped surface normal    
                                    float3 L, // Points to light    
                                    float3 V, // Points to eye    
                                    float m,  // Roughness    
                                    float rho_s, // Specular brightness    
                                    sampler2D beckmannTex ) 
            {   
                float result = 0.0;   
                float ndotl = dot( N, L ); 
                if( ndotl > 0.0 ) 
                {    
                    float3 h = L + V; // Unnormalized half-way vector    
                    float3 H = normalize( h );    
                    float ndoth = dot( N, H );    
                    float PH = pow( 2.0*tex2D(beckmannTex,float2(ndoth,m)), 10.0 );    
                    float F = Fresnel_Skin(dot(H,V));    
                    float frSpec = max( PH * F / dot( h, h ), 0 );    
                    result = ndotl * rho_s * frSpec; // BRDF * dot(N,L) * rho_s  
                }  
                return result; 
            }
            
            float Specular_Beckman_Skin( float3 N, // Bumped surface normal    
                                    float3 L, // Points to light    
                                    float3 V, // Points to eye    
                                    float Roughness,  // Roughness    
                                    float rho_s // Specular brightness
                                    ) 
            {   
                float result = 0.0;   
                float ndotl = dot( N, L ); 
                if( ndotl > 0.0 ) 
                {    
                    float3 h = L + V; // Unnormalized half-way vector    
                    float3 H = normalize( h );    
                    float ndoth = dot( N, H );    
                    float PH = pow( 2.0* KSTextureCompute(float2(ndoth,Roughness)), 10.0 ); 
                    float F = Fresnel_Skin(dot(H,V));    
                    float frSpec = max( PH * F / dot( h, h ), 0 );    
                    result = ndotl * rho_s * frSpec; // BRDF * dot(N,L) * rho_s  
                }  
                return result; 
            } 

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col = 1;
                float2 uv = i.uv;
                uv= clamp(uv,0.001,0.999);
                return KSTextureCompute(uv).xxxx;
                return pow( KSTextureCompute(uv).xxxx,1/2.2);

                return  saturate(col);
            }
            ENDCG
        }
    }
     FallBack "Diffuse" //为了正确地获取到Shadow
}
