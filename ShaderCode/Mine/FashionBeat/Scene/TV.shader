// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// 注意：手动更改此数据可能会妨碍您在 Shader Forge 中打开它
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:2345,x:32968,y:32692,varname:node_2345,prsc:2|custl-9607-RGB,alpha-9607-A;n:type:ShaderForge.SFN_UVTile,id:8084,x:32147,y:32771,varname:node_8084,prsc:2|UVIN-5573-OUT,WDT-160-OUT,HGT-3464-OUT,TILE-6263-OUT;n:type:ShaderForge.SFN_Tex2d,id:9607,x:32470,y:32733,ptovrint:False,ptlb:node_9607,ptin:_node_9607,varname:_node_9607,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-8084-UVOUT;n:type:ShaderForge.SFN_ValueProperty,id:160,x:31752,y:32845,ptovrint:False,ptlb:node_160,ptin:_node_160,varname:_node_160,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:7683,x:31302,y:33025,ptovrint:False,ptlb:node_7683,ptin:_node_7683,varname:_node_7683,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:2049,x:31813,y:33219,ptovrint:False,ptlb:node_2049,ptin:_node_2049,varname:_node_2049,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Time,id:9526,x:31506,y:33514,varname:node_9526,prsc:2;n:type:ShaderForge.SFN_Multiply,id:5714,x:32047,y:33278,varname:node_5714,prsc:2|A-2049-OUT,B-7651-OUT;n:type:ShaderForge.SFN_TexCoord,id:9134,x:31158,y:32453,varname:node_9134,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_RemapRange,id:9349,x:31414,y:32611,varname:node_9349,prsc:2,frmn:0,frmx:1,tomn:1,tomx:0|IN-9134-V;n:type:ShaderForge.SFN_Append,id:5573,x:31693,y:32442,varname:node_5573,prsc:2|A-9134-U,B-9349-OUT;n:type:ShaderForge.SFN_Negate,id:3464,x:31558,y:33053,varname:node_3464,prsc:2|IN-7683-OUT;n:type:ShaderForge.SFN_Trunc,id:6263,x:32288,y:33188,varname:node_6263,prsc:2|IN-5714-OUT;n:type:ShaderForge.SFN_ValueProperty,id:596,x:31572,y:33852,ptovrint:False,ptlb:node_596,ptin:_node_596,varname:_node_596,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:7651,x:31855,y:33532,varname:node_7651,prsc:2|A-9526-T,B-596-OUT;proporder:9607-160-7683-2049-596;pass:END;sub:END;*/

Shader "America/Scene/TV" {
    Properties {
        _node_9607 ("node_9607", 2D) = "white" {}
        _node_160 ("node_160", Float ) = 0
        _node_7683 ("node_7683", Float ) = 0
        _node_2049 ("node_2049", Float ) = 0
        _node_596 ("node_596", Float ) = 0
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
            uniform sampler2D _node_9607; uniform float4 _node_9607_ST;
            uniform float _node_160;
            uniform float _node_7683;
            uniform float _node_2049;
            uniform float _node_596;
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
                float4 node_9526 = _Time;
                float node_6263 = trunc((_node_2049*(node_9526.g*_node_596)));
                float2 node_8084_tc_rcp = float2(1.0,1.0)/float2( _node_160, (-1*_node_7683) );
                float node_8084_ty = floor(node_6263 * node_8084_tc_rcp.x);
                float node_8084_tx = node_6263 - _node_160 * node_8084_ty;
                float2 node_8084 = (float2(i.uv0.r,(i.uv0.g*-1.0+1.0)) + float2(node_8084_tx, node_8084_ty)) * node_8084_tc_rcp;
                float4 _node_9607_var = tex2D(_node_9607,TRANSFORM_TEX(node_8084, _node_9607));
                float3 finalColor = _node_9607_var.rgb;
                fixed4 finalRGBA = fixed4(finalColor,_node_9607_var.a);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
