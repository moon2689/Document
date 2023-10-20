// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// 注意：手动更改此数据可能会妨碍您在 Shader Forge 中打开它
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33312,y:32712,varname:node_3138,prsc:2|emission-9199-OUT,custl-8425-RGB,alpha-3909-OUT;n:type:ShaderForge.SFN_Tex2d,id:8425,x:31651,y:32469,ptovrint:False,ptlb:Main Tex,ptin:_MainTex,varname:_MainTex,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:8734,x:32752,y:32464,varname:node_8734,prsc:0|A-8425-RGB,B-8067-OUT;n:type:ShaderForge.SFN_Sin,id:8581,x:32042,y:33134,varname:node_8581,prsc:0|IN-2045-OUT;n:type:ShaderForge.SFN_Time,id:4740,x:31279,y:33233,varname:node_4740,prsc:0;n:type:ShaderForge.SFN_Multiply,id:2045,x:31740,y:33121,varname:node_2045,prsc:2|A-4740-TDB,B-7967-OUT;n:type:ShaderForge.SFN_Vector1,id:2413,x:32105,y:33480,varname:node_2413,prsc:0,v1:-0.7;n:type:ShaderForge.SFN_Subtract,id:8067,x:32397,y:33241,varname:node_8067,prsc:2|A-8581-OUT,B-2413-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7967,x:31306,y:33613,ptovrint:False,ptlb:node_7967,ptin:_node_7967,varname:_node_7967,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:3909,x:32168,y:32777,varname:node_3909,prsc:2|A-8425-A,B-8568-OUT;n:type:ShaderForge.SFN_ValueProperty,id:8568,x:31822,y:32826,ptovrint:True,ptlb:node_8568,ptin:_node_8568,varname:_node_8568,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:9199,x:32933,y:33046,varname:node_9199,prsc:2|A-8734-OUT,B-8381-RGB;n:type:ShaderForge.SFN_Color,id:8381,x:32726,y:33159,ptovrint:False,ptlb:node_8381,ptin:_node_8381,varname:_node_8381,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;proporder:8425-7967-8568-8381;pass:END;sub:END;*/

Shader "America/Scene/Self-Illumin flicker" {
    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}
        _node_7967 ("node_7967", Float ) = 0
        _node_8568 ("node_8568", Float ) = 0
        _node_8381 ("node_8381", Color) = (0.5,0.5,0.5,1)
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
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
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float _node_7967;
            uniform float _node_8568;
            uniform float4 _node_8381;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                fixed4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                fixed4 node_4740 = _Time;
                float3 emissive = ((_MainTex_var.rgb*(sin((node_4740.b*_node_7967))-(-0.7)))*_node_8381.rgb);
                float3 finalColor = emissive + _MainTex_var.rgb;
                return fixed4(finalColor,(_MainTex_var.a*_node_8568));
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
