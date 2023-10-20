// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// 注意：手动更改此数据可能会妨碍您在 Shader Forge 中打开它
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:7772,x:33146,y:32681,varname:node_7772,prsc:2|emission-4126-OUT,custl-4126-OUT,alpha-8756-A;n:type:ShaderForge.SFN_Fresnel,id:9063,x:32110,y:32983,varname:node_9063,prsc:2|NRM-5971-OUT,EXP-5877-OUT;n:type:ShaderForge.SFN_Multiply,id:4126,x:32600,y:32869,varname:node_4126,prsc:2|A-8756-RGB,B-9063-OUT,C-8625-RGB;n:type:ShaderForge.SFN_Tex2d,id:8756,x:32077,y:32691,ptovrint:False,ptlb:node_8756,ptin:_node_8756,varname:_node_8756,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_NormalVector,id:5971,x:31647,y:32928,prsc:2,pt:False;n:type:ShaderForge.SFN_ValueProperty,id:5877,x:31808,y:33143,ptovrint:False,ptlb:node_5877,ptin:_node_5877,varname:_node_5877,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Panner,id:7229,x:32041,y:33225,varname:node_7229,prsc:2,spu:0,spv:-0.3|UVIN-4615-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:4615,x:31716,y:33273,varname:node_4615,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Tex2d,id:8625,x:32416,y:33180,ptovrint:False,ptlb:node_8625,ptin:_node_8625,varname:_node_8625,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-7229-UVOUT;proporder:8756-5877-8625;pass:END;sub:END;*/

Shader "America/shinning flow" {
    Properties {
        _node_8756 ("node_8756", 2D) = "white" {}
        _node_5877 ("node_5877", Float ) = 0
        _node_8625 ("node_8625", 2D) = "white" {}
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
            uniform sampler2D _node_8756; uniform float4 _node_8756_ST;
            uniform float _node_5877;
            uniform sampler2D _node_8625; uniform float4 _node_8625_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                UNITY_FOG_COORDS(3)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                float4 _node_8756_var = tex2D(_node_8756,TRANSFORM_TEX(i.uv0, _node_8756));
                float4 node_1907 = _Time;
                float2 node_7229 = (i.uv0+node_1907.g*float2(0,-0.3));
                fixed4 _node_8625_var = tex2D(_node_8625,TRANSFORM_TEX(node_7229, _node_8625));
                float3 node_4126 = (_node_8756_var.rgb*pow(1.0-max(0,dot(i.normalDir, viewDirection)),_node_5877)*_node_8625_var.rgb);
                float3 emissive = node_4126;
                float3 finalColor = emissive + node_4126;
                fixed4 finalRGBA = fixed4(finalColor,_node_8756_var.a);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
