// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// 注意：手动更改此数据可能会妨碍您在 Shader Forge 中打开它
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:False,igpj:True,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:7642,x:32937,y:32830,varname:node_7642,prsc:2|diff-7441-OUT,emission-7582-OUT,custl-8664-OUT,alpha-2294-A;n:type:ShaderForge.SFN_TexCoord,id:1974,x:31602,y:33009,varname:node_1974,prsc:2,uv:1,uaff:False;n:type:ShaderForge.SFN_Multiply,id:7441,x:32366,y:32869,varname:node_7441,prsc:2|A-2294-RGB,B-7825-RGB;n:type:ShaderForge.SFN_Tex2d,id:7825,x:32036,y:32935,ptovrint:False,ptlb:Lightmap,ptin:_Lightmap,varname:_Lightmap,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-1974-UVOUT;n:type:ShaderForge.SFN_Tex2d,id:2294,x:31876,y:32531,ptovrint:False,ptlb:Maintex,ptin:_Maintex,varname:_Maintex,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-2862-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:2862,x:31488,y:32507,varname:node_2862,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Cubemap,id:8770,x:31773,y:33230,ptovrint:False,ptlb:Cubemap,ptin:_Cubemap,varname:_Cubemap,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,pvfc:0;n:type:ShaderForge.SFN_Multiply,id:1241,x:32218,y:33232,varname:node_1241,prsc:2|A-8770-RGB,B-6417-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6417,x:31759,y:33495,ptovrint:False,ptlb:Reflection Intensity,ptin:_ReflectionIntensity,varname:_ReflectionIntensity,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Tex2d,id:8713,x:32412,y:33428,ptovrint:False,ptlb:Noise,ptin:_Noise,varname:_Noise,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:8400,x:32597,y:33201,varname:node_8400,prsc:2|A-1241-OUT,B-8713-RGB;n:type:ShaderForge.SFN_Multiply,id:7582,x:32560,y:32910,varname:node_7582,prsc:2|A-7441-OUT,B-9924-OUT;n:type:ShaderForge.SFN_ValueProperty,id:9924,x:32307,y:33102,ptovrint:False,ptlb:self-luminous ,ptin:_selfluminous,varname:_selfluminous,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:8664,x:32732,y:33070,varname:node_8664,prsc:2|A-7582-OUT,B-8400-OUT;proporder:2294-7825-8770-6417-8713-9924;pass:END;sub:END;*/

Shader "America/Scene/2Ufanshe" {
    Properties {
        _Maintex ("Maintex", 2D) = "white" {}
        _Lightmap ("Lightmap", 2D) = "white" {}
        _Cubemap ("Cubemap", Cube) = "_Skybox" {}
        _ReflectionIntensity ("Reflection Intensity", Float ) = 0
        _Noise ("Noise", 2D) = "white" {}
        _selfluminous ("self-luminous ", Float ) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "RenderType"="Opaque"
        }
        LOD 100
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform sampler2D _Lightmap; uniform float4 _Lightmap_ST;
            uniform sampler2D _Maintex; uniform float4 _Maintex_ST;
            uniform samplerCUBE _Cubemap;
            uniform float _ReflectionIntensity;
            uniform sampler2D _Noise; uniform float4 _Noise_ST;
            uniform float _selfluminous;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 posWorld : TEXCOORD2;
                float3 normalDir : TEXCOORD3;
                UNITY_FOG_COORDS(4)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
////// Lighting:
////// Emissive:
                fixed4 _Maintex_var = tex2D(_Maintex,TRANSFORM_TEX(i.uv0, _Maintex));
                fixed4 _Lightmap_var = tex2D(_Lightmap,TRANSFORM_TEX(i.uv1, _Lightmap));
                float3 node_7441 = (_Maintex_var.rgb*_Lightmap_var.rgb);
                float3 node_7582 = (node_7441*_selfluminous);
                float3 emissive = node_7582;
                float4 _Noise_var = tex2D(_Noise,TRANSFORM_TEX(i.uv0, _Noise));
                float3 finalColor = emissive + (node_7582*((texCUBE(_Cubemap,viewReflectDirection).rgb*_ReflectionIntensity)*_Noise_var.rgb));
                fixed4 finalRGBA = fixed4(finalColor,_Maintex_var.a);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            struct VertexInput {
                float4 vertex : POSITION;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
