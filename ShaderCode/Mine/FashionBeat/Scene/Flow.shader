// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// 注意：手动更改此数据可能会妨碍您在 Shader Forge 中打开它
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33337,y:32712,varname:node_3138,prsc:2|emission-7643-OUT,custl-4542-OUT,alpha-4467-OUT;n:type:ShaderForge.SFN_Tex2d,id:5520,x:32459,y:32822,ptovrint:False,ptlb:Main Tex,ptin:_MainTex,varname:_MainTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-6945-UVOUT;n:type:ShaderForge.SFN_Panner,id:6945,x:31942,y:32859,varname:node_6945,prsc:2,spu:1,spv:1|UVIN-4190-UVOUT,DIST-5707-OUT;n:type:ShaderForge.SFN_TexCoord,id:4190,x:31379,y:32846,varname:node_4190,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Vector4Property,id:8495,x:31109,y:33044,ptovrint:False,ptlb:Flow Speed,ptin:_FlowSpeed,varname:_FlowSpeed,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0,v2:0,v3:0,v4:0;n:type:ShaderForge.SFN_Multiply,id:5707,x:31606,y:33142,varname:node_5707,prsc:2|A-8495-XYZ,B-7958-T;n:type:ShaderForge.SFN_Time,id:7958,x:31124,y:33388,varname:node_7958,prsc:0;n:type:ShaderForge.SFN_Tex2d,id:5529,x:32485,y:33482,ptovrint:False,ptlb:Mask,ptin:_Mask,varname:_Mask,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_ChannelBlend,id:4467,x:32845,y:33065,varname:node_4467,prsc:2,chbt:0|M-5529-A,R-5520-A;n:type:ShaderForge.SFN_ValueProperty,id:7643,x:32732,y:32687,ptovrint:False,ptlb:Illumin Intensity,ptin:_IlluminIntensity,varname:_IlluminIntensity,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:4542,x:32897,y:32795,varname:node_4542,prsc:2|A-5520-RGB,B-5529-RGB,C-8415-RGB;n:type:ShaderForge.SFN_Color,id:8415,x:32296,y:33104,ptovrint:False,ptlb:node_8415,ptin:_node_8415,varname:_node_8415,prsc:2,glob:False,taghide:False,taghdr:True,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;proporder:5520-8495-5529-7643-8415;pass:END;sub:END;*/

Shader "America/Scene/Flow" {
    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}
        _FlowSpeed ("Flow Speed", Vector) = (0,0,0,0)
        _Mask ("Mask", 2D) = "white" {}
        _IlluminIntensity ("Illumin Intensity", Float ) = 0
        [HDR]_node_8415 ("node_8415", Color) = (0.5,0.5,0.5,1)
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
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _FlowSpeed;
            uniform sampler2D _Mask; uniform float4 _Mask_ST;
            uniform float _IlluminIntensity;
            uniform float4 _node_8415;
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
                float3 emissive = float3(_IlluminIntensity,_IlluminIntensity,_IlluminIntensity);
                fixed4 node_7958 = _Time;
                float2 node_6945 = (i.uv0+(_FlowSpeed.rgb*node_7958.g)*float2(1,1));
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_6945, _MainTex));
                float4 _Mask_var = tex2D(_Mask,TRANSFORM_TEX(i.uv0, _Mask));
                float3 finalColor = emissive + (_MainTex_var.rgb*_Mask_var.rgb*_node_8415.rgb);
                return fixed4(finalColor,(_Mask_var.a.r*_MainTex_var.a));
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
