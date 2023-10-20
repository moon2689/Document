// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// 注意：手动更改此数据可能会妨碍您在 Shader Forge 中打开它
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:8166,x:33047,y:32711,varname:node_8166,prsc:2|emission-41-OUT,alpha-6493-A;n:type:ShaderForge.SFN_Tex2d,id:6493,x:31757,y:32453,ptovrint:False,ptlb:Main Tex,ptin:_MainTex,varname:_MainTex,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-6299-UVOUT;n:type:ShaderForge.SFN_Tex2d,id:1941,x:32323,y:33010,ptovrint:False,ptlb:Flow Tex,ptin:_FlowTex,varname:_FlowTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-4604-UVOUT;n:type:ShaderForge.SFN_Panner,id:4604,x:32054,y:32832,varname:node_4604,prsc:2,spu:0,spv:1|UVIN-9375-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:9375,x:31703,y:32824,varname:node_9375,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:41,x:32631,y:32802,varname:node_41,prsc:2|A-6493-A,B-1941-RGB,C-6983-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6983,x:32297,y:32856,ptovrint:False,ptlb:Diffuse Rate,ptin:_DiffuseRate,varname:_DiffuseRate,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_TexCoord,id:7466,x:31028,y:32436,varname:node_7466,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Panner,id:6299,x:31311,y:32453,varname:node_6299,prsc:2,spu:0,spv:0.2|UVIN-7466-UVOUT;proporder:6493-1941-6983;pass:END;sub:END;*/

Shader "America/Alpha Flow" {
    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}
        _FlowTex ("Flow Tex", 2D) = "white" {}
        _DiffuseRate ("Diffuse Rate", Float ) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        LOD 100
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _FlowTex; uniform float4 _FlowTex_ST;
            uniform float _DiffuseRate;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float4 node_8546 = _Time;
                float2 node_6299 = (i.uv0+node_8546.g*float2(0,0.2));
                fixed4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_6299, _MainTex));
                float2 node_4604 = (i.uv0+node_8546.g*float2(0,1));
                float4 _FlowTex_var = tex2D(_FlowTex,TRANSFORM_TEX(node_4604, _FlowTex));
                float3 emissive = (_MainTex_var.a*_FlowTex_var.rgb*_DiffuseRate);
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,_MainTex_var.a);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
