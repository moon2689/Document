// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// 注意：手动更改此数据可能会妨碍您在 Shader Forge 中打开它
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:0,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:False,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:True,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:2647,x:34563,y:32168,varname:node_2647,prsc:2|alpha-9906-OUT,refract-1242-OUT;n:type:ShaderForge.SFN_Multiply,id:1242,x:32772,y:32664,varname:node_1242,prsc:2|A-1424-RGB,B-5827-OUT;n:type:ShaderForge.SFN_Slider,id:5827,x:31704,y:33476,ptovrint:False,ptlb:node_5827,ptin:_node_5827,varname:_node_5827,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.0940171,max:1;n:type:ShaderForge.SFN_TexCoord,id:7123,x:30905,y:32884,varname:node_7123,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Length,id:29,x:31441,y:32831,varname:node_29,prsc:2|IN-1990-OUT;n:type:ShaderForge.SFN_RemapRange,id:1990,x:31187,y:32862,varname:node_1990,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-7123-UVOUT;n:type:ShaderForge.SFN_ComponentMask,id:2188,x:31381,y:33102,varname:node_2188,prsc:2,cc1:0,cc2:1,cc3:-1,cc4:-1|IN-1990-OUT;n:type:ShaderForge.SFN_ArcTan2,id:3050,x:31708,y:33043,varname:node_3050,prsc:2,attp:2|A-2188-R,B-2188-G;n:type:ShaderForge.SFN_Append,id:992,x:31983,y:32904,varname:node_992,prsc:1|A-8912-OUT,B-3050-OUT;n:type:ShaderForge.SFN_Time,id:4150,x:30808,y:32365,varname:node_4150,prsc:0;n:type:ShaderForge.SFN_Slider,id:2567,x:31005,y:32650,ptovrint:False,ptlb:node_2567,ptin:_node_2567,varname:_node_2567,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:10;n:type:ShaderForge.SFN_Multiply,id:1362,x:31660,y:32522,varname:node_1362,prsc:2|A-8375-OUT,B-2567-OUT;n:type:ShaderForge.SFN_Add,id:8912,x:31941,y:32588,varname:node_8912,prsc:2|A-1362-OUT,B-29-OUT;n:type:ShaderForge.SFN_Tex2d,id:1424,x:32186,y:32861,ptovrint:False,ptlb:node_1424,ptin:_node_1424,varname:_node_1424,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-992-OUT;n:type:ShaderForge.SFN_OneMinus,id:8375,x:31181,y:32409,varname:node_8375,prsc:2|IN-4150-TSL;n:type:ShaderForge.SFN_ValueProperty,id:9906,x:34123,y:32161,ptovrint:False,ptlb:node_9906,ptin:_node_9906,varname:_node_9906,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;proporder:5827-2567-1424-9906;pass:END;sub:END;*/

Shader "America/Scene/Lianyi2" {
    Properties {
        _node_5827 ("node_5827", Range(0, 1)) = 0.0940171
        _node_2567 ("node_2567", Range(0, 10)) = 0
        _node_1424 ("node_1424", 2D) = "white" {}
        _node_9906 ("node_9906", Float ) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        LOD 100
        GrabPass{ "Refraction" }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            Stencil {
                Ref 128
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform sampler2D Refraction;
            uniform half _node_5827;
            uniform float _node_2567;
            uniform sampler2D _node_1424; uniform float4 _node_1424_ST;
            uniform float _node_9906;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 projPos : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                fixed4 node_4150 = _Time;
                float2 node_1990 = (i.uv0*2.0+-1.0);
                float2 node_2188 = node_1990.rg;
                half2 node_992 = float2((((1.0 - node_4150.r)*_node_2567)+length(node_1990)),((atan2(node_2188.r,node_2188.g)/6.28318530718)+0.5));
                half4 _node_1424_var = tex2D(_node_1424,TRANSFORM_TEX(node_992, _node_1424));
                float2 sceneUVs = (i.projPos.xy / i.projPos.w) + (_node_1424_var.rgb*_node_5827).rg;
                float4 sceneColor = tex2D(Refraction, sceneUVs);
////// Lighting:
                float3 finalColor = 0;
                return fixed4(lerp(sceneColor.rgb, finalColor,_node_9906),1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
