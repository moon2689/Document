// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// 注意：手动更改此数据可能会妨碍您在 Shader Forge 中打开它
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:7137,x:32719,y:32712,varname:node_7137,prsc:2|diff-8337-OUT,alpha-3739-OUT,refract-6901-OUT,voffset-6391-OUT;n:type:ShaderForge.SFN_Tex2d,id:3245,x:31417,y:32815,ptovrint:False,ptlb:Main Tex,ptin:_MainTex,varname:_MainTex,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-5076-UVOUT;n:type:ShaderForge.SFN_Panner,id:5076,x:31073,y:32849,varname:node_5076,prsc:0,spu:0.1,spv:-0.1|UVIN-9189-UVOUT,DIST-6642-TSL;n:type:ShaderForge.SFN_TexCoord,id:9189,x:30751,y:32766,varname:node_9189,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Slider,id:2004,x:31146,y:33162,ptovrint:False,ptlb:Flow Intensity,ptin:_FlowIntensity,varname:_FlowIntensity,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.5299156,max:1;n:type:ShaderForge.SFN_Time,id:6642,x:30767,y:33004,varname:node_6642,prsc:0;n:type:ShaderForge.SFN_Vector1,id:3739,x:31840,y:32914,varname:node_3739,prsc:2,v1:0.1;n:type:ShaderForge.SFN_Append,id:4015,x:31688,y:32812,varname:node_4015,prsc:2|A-3245-R,B-3245-R;n:type:ShaderForge.SFN_Multiply,id:6901,x:32146,y:32743,varname:node_6901,prsc:2|A-4015-OUT,B-2004-OUT;n:type:ShaderForge.SFN_Tex2d,id:9280,x:31851,y:32337,ptovrint:False,ptlb:node_9280,ptin:_node_9280,varname:_node_9280,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-5076-UVOUT;n:type:ShaderForge.SFN_Multiply,id:8337,x:32406,y:32479,varname:node_8337,prsc:2|A-9280-RGB,B-1657-RGB;n:type:ShaderForge.SFN_Color,id:1657,x:31948,y:32540,ptovrint:False,ptlb:node_1657,ptin:_node_1657,varname:_node_1657,prsc:0,glob:False,taghide:False,taghdr:True,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_FragmentPosition,id:9021,x:31829,y:33152,varname:node_9021,prsc:2;n:type:ShaderForge.SFN_Multiply,id:6391,x:32387,y:33063,varname:node_6391,prsc:2|A-6901-OUT,B-9021-W,C-5355-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5355,x:32119,y:33311,ptovrint:False,ptlb:node_5355,ptin:_node_5355,varname:_node_5355,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;proporder:3245-2004-9280-1657-5355;pass:END;sub:END;*/

Shader "America/Scene/water ripple" {
    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}
        _FlowIntensity ("Flow Intensity", Range(0, 1)) = 0.5299156
        _node_9280 ("node_9280", 2D) = "white" {}
        [HDR]_node_1657 ("node_1657", Color) = (0.5,0.5,0.5,1)
        _node_5355 ("node_5355", Float ) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        LOD 100
        GrabPass{ }
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
            uniform float4 _LightColor0;
            uniform sampler2D _GrabTexture;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform fixed _FlowIntensity;
            uniform sampler2D _node_9280; uniform float4 _node_9280_ST;
            uniform fixed4 _node_1657;
            uniform float _node_5355;
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
                float4 projPos : TEXCOORD3;
                UNITY_FOG_COORDS(4)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                fixed4 node_6642 = _Time;
                fixed2 node_5076 = (o.uv0+node_6642.r*float2(0.1,-0.1));
                fixed4 _MainTex_var = tex2Dlod(_MainTex,float4(TRANSFORM_TEX(node_5076, _MainTex),0.0,0));
                float2 node_6901 = (float2(_MainTex_var.r,_MainTex_var.r)*_FlowIntensity);
                v.vertex.xyz += float3((node_6901*mul(unity_ObjectToWorld, v.vertex).a*_node_5355),0.0);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                fixed4 node_6642 = _Time;
                fixed2 node_5076 = (i.uv0+node_6642.r*float2(0.1,-0.1));
                fixed4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_5076, _MainTex));
                float2 node_6901 = (float2(_MainTex_var.r,_MainTex_var.r)*_FlowIntensity);
                float2 sceneUVs = (i.projPos.xy / i.projPos.w) + node_6901;
                float4 sceneColor = tex2D(_GrabTexture, sceneUVs);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation = 1;
                float3 attenColor = attenuation * _LightColor0.xyz;
/////// Diffuse:
                float NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float3 indirectDiffuse = float3(0,0,0);
                indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; // Ambient Light
                fixed4 _node_9280_var = tex2D(_node_9280,TRANSFORM_TEX(node_5076, _node_9280));
                float3 diffuseColor = (_node_9280_var.rgb*_node_1657.rgb);
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse;
                fixed4 finalRGBA = fixed4(lerp(sceneColor.rgb, finalColor,0.1),1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _GrabTexture;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform fixed _FlowIntensity;
            uniform sampler2D _node_9280; uniform float4 _node_9280_ST;
            uniform fixed4 _node_1657;
            uniform float _node_5355;
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
                float4 projPos : TEXCOORD3;
                LIGHTING_COORDS(4,5)
                UNITY_FOG_COORDS(6)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                fixed4 node_6642 = _Time;
                fixed2 node_5076 = (o.uv0+node_6642.r*float2(0.1,-0.1));
                fixed4 _MainTex_var = tex2Dlod(_MainTex,float4(TRANSFORM_TEX(node_5076, _MainTex),0.0,0));
                float2 node_6901 = (float2(_MainTex_var.r,_MainTex_var.r)*_FlowIntensity);
                v.vertex.xyz += float3((node_6901*mul(unity_ObjectToWorld, v.vertex).a*_node_5355),0.0);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                fixed4 node_6642 = _Time;
                fixed2 node_5076 = (i.uv0+node_6642.r*float2(0.1,-0.1));
                fixed4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_5076, _MainTex));
                float2 node_6901 = (float2(_MainTex_var.r,_MainTex_var.r)*_FlowIntensity);
                float2 sceneUVs = (i.projPos.xy / i.projPos.w) + node_6901;
                float4 sceneColor = tex2D(_GrabTexture, sceneUVs);
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
/////// Diffuse:
                float NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                fixed4 _node_9280_var = tex2D(_node_9280,TRANSFORM_TEX(node_5076, _node_9280));
                float3 diffuseColor = (_node_9280_var.rgb*_node_1657.rgb);
                float3 diffuse = directDiffuse * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse;
                fixed4 finalRGBA = fixed4(finalColor * 0.1,0);
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
            Cull Back
            
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
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform fixed _FlowIntensity;
            uniform float _node_5355;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
                float4 posWorld : TEXCOORD2;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                fixed4 node_6642 = _Time;
                fixed2 node_5076 = (o.uv0+node_6642.r*float2(0.1,-0.1));
                fixed4 _MainTex_var = tex2Dlod(_MainTex,float4(TRANSFORM_TEX(node_5076, _MainTex),0.0,0));
                float2 node_6901 = (float2(_MainTex_var.r,_MainTex_var.r)*_FlowIntensity);
                v.vertex.xyz += float3((node_6901*mul(unity_ObjectToWorld, v.vertex).a*_node_5355),0.0);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
