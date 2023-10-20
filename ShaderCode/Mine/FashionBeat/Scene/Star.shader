// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// 注意：手动更改此数据可能会妨碍您在 Shader Forge 中打开它
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:5491,x:33205,y:32667,varname:node_5491,prsc:2|emission-4209-OUT,custl-9909-OUT,alpha-8723-A;n:type:ShaderForge.SFN_Tex2d,id:8723,x:32172,y:32436,ptovrint:False,ptlb:node_8723,ptin:_node_8723,varname:_node_8723,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:8544,x:32143,y:32813,ptovrint:False,ptlb:node_8544,ptin:_node_8544,varname:_node_8544,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-3314-UVOUT;n:type:ShaderForge.SFN_Multiply,id:9909,x:32824,y:32909,varname:node_9909,prsc:2|A-8723-RGB,B-8544-RGB;n:type:ShaderForge.SFN_Panner,id:3314,x:31779,y:32854,varname:node_3314,prsc:2,spu:0.1,spv:0.1|UVIN-4162-UVOUT,DIST-331-OUT;n:type:ShaderForge.SFN_TexCoord,id:4162,x:31497,y:32816,varname:node_4162,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Color,id:715,x:32233,y:33247,ptovrint:False,ptlb:node_715,ptin:_node_715,varname:_node_715,prsc:2,glob:False,taghide:False,taghdr:True,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:4209,x:32937,y:32465,varname:node_4209,prsc:2|A-8723-RGB,B-5856-OUT,C-715-RGB;n:type:ShaderForge.SFN_ValueProperty,id:5856,x:32647,y:32571,ptovrint:False,ptlb:node_5856,ptin:_node_5856,varname:_node_5856,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Slider,id:8344,x:31185,y:33113,ptovrint:False,ptlb:node_8344,ptin:_node_8344,varname:_node_8344,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:3;n:type:ShaderForge.SFN_Time,id:2382,x:31234,y:33314,varname:node_2382,prsc:2;n:type:ShaderForge.SFN_Multiply,id:331,x:31661,y:33159,varname:node_331,prsc:2|A-8344-OUT,B-2382-T;proporder:8723-8544-715-5856-8344;pass:END;sub:END;*/

Shader "America/Scene/Star" {
    Properties {
        _node_8723 ("node_8723", 2D) = "white" {}
        _node_8544 ("node_8544", 2D) = "white" {}
        [HDR]_node_715 ("node_715", Color) = (0.5,0.5,0.5,1)
        _node_5856 ("node_5856", Float ) = 0
        _node_8344 ("node_8344", Range(0, 3)) = 0
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
            uniform sampler2D _node_8723; uniform float4 _node_8723_ST;
            uniform sampler2D _node_8544; uniform float4 _node_8544_ST;
            uniform float4 _node_715;
            uniform float _node_5856;
            uniform float _node_8344;
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
                float4 _node_8723_var = tex2D(_node_8723,TRANSFORM_TEX(i.uv0, _node_8723));
                float3 emissive = (_node_8723_var.rgb*_node_5856*_node_715.rgb);
                float4 node_2382 = _Time;
                float2 node_3314 = (i.uv0+(_node_8344*node_2382.g)*float2(0.1,0.1));
                float4 _node_8544_var = tex2D(_node_8544,TRANSFORM_TEX(node_3314, _node_8544));
                float3 finalColor = emissive + (_node_8723_var.rgb*_node_8544_var.rgb);
                fixed4 finalRGBA = fixed4(finalColor,_node_8723_var.a);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
