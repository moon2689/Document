// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// 注意：手动更改此数据可能会妨碍您在 Shader Forge 中打开它
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:5284,x:33061,y:32582,varname:node_5284,prsc:2|diff-1125-OUT,spec-5164-OUT,emission-9093-OUT,amdfl-4315-OUT;n:type:ShaderForge.SFN_Tex2d,id:8521,x:30985,y:32436,ptovrint:False,ptlb:main tex,ptin:_maintex,varname:_maintex,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:5144,x:31185,y:32695,ptovrint:False,ptlb:Alpha,ptin:_Alpha,varname:_Alpha,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Cubemap,id:7347,x:31325,y:33441,ptovrint:False,ptlb:Cubemap,ptin:_Cubemap,varname:_Cubemap,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,pvfc:0;n:type:ShaderForge.SFN_Tex2d,id:5487,x:31026,y:33253,ptovrint:False,ptlb:Alpha2,ptin:_Alpha2,varname:_Alpha2,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:1125,x:32422,y:32464,varname:node_1125,prsc:2|A-8521-RGB,B-1662-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1662,x:31757,y:32599,ptovrint:False,ptlb:node_1662,ptin:_node_1662,varname:_node_1662,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:9093,x:31808,y:32830,varname:node_9093,prsc:2|A-8521-RGB,B-5144-A,C-2568-OUT,D-6376-OUT;n:type:ShaderForge.SFN_Time,id:2800,x:30566,y:33146,varname:node_2800,prsc:0;n:type:ShaderForge.SFN_Vector1,id:6376,x:31277,y:33075,varname:node_6376,prsc:0,v1:0.5;n:type:ShaderForge.SFN_Sin,id:2568,x:31035,y:32962,varname:node_2568,prsc:2|IN-9555-OUT;n:type:ShaderForge.SFN_Add,id:9555,x:30791,y:33040,varname:node_9555,prsc:2|A-4264-OUT,B-2800-TDB;n:type:ShaderForge.SFN_Pi,id:3426,x:30246,y:32979,varname:node_3426,prsc:2;n:type:ShaderForge.SFN_VertexColor,id:1629,x:30246,y:32831,varname:node_1629,prsc:2;n:type:ShaderForge.SFN_Multiply,id:4264,x:30540,y:32897,varname:node_4264,prsc:2|A-1629-B,B-3426-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5164,x:32259,y:32640,ptovrint:False,ptlb:node_5164,ptin:_node_5164,varname:_node_5164,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Add,id:4315,x:31925,y:33331,varname:node_4315,prsc:2|A-5487-A,B-7347-RGB;proporder:8521-5144-5487-7347-1662-5164;pass:END;sub:END;*/

Shader "America/Scene/Alpha self-luminous&reflect" {
    Properties {
        _maintex ("main tex", 2D) = "white" {}
        _Alpha ("Alpha", 2D) = "white" {}
        _Alpha2 ("Alpha2", 2D) = "white" {}
        _Cubemap ("Cubemap", Cube) = "_Skybox" {}
        _node_1662 ("node_1662", Float ) = 0
        _node_5164 ("node_5164", Float ) = 0
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        LOD 100
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _maintex; uniform float4 _maintex_ST;
            uniform sampler2D _Alpha; uniform float4 _Alpha_ST;
            uniform samplerCUBE _Cubemap;
            uniform sampler2D _Alpha2; uniform float4 _Alpha2_ST;
            uniform float _node_1662;
            uniform float _node_5164;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 vertexColor : COLOR;
                LIGHTING_COORDS(3,4)
                UNITY_FOG_COORDS(5)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                float gloss = 0.5;
                float specPow = exp2( gloss * 10.0 + 1.0 );
////// Specular:
                float NdotL = saturate(dot( normalDirection, lightDirection ));
                float3 specularColor = float3(_node_5164,_node_5164,_node_5164);
                float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow)*specularColor;
                float3 specular = directSpecular;
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float3 indirectDiffuse = float3(0,0,0);
                indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; // Ambient Light
                float4 _Alpha2_var = tex2D(_Alpha2,TRANSFORM_TEX(i.uv0, _Alpha2));
                indirectDiffuse += (_Alpha2_var.a+texCUBE(_Cubemap,viewReflectDirection).rgb); // Diffuse Ambient Light
                fixed4 _maintex_var = tex2D(_maintex,TRANSFORM_TEX(i.uv0, _maintex));
                float3 diffuseColor = (_maintex_var.rgb*_node_1662);
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
////// Emissive:
                fixed4 _Alpha_var = tex2D(_Alpha,TRANSFORM_TEX(i.uv0, _Alpha));
                fixed4 node_2800 = _Time;
                float3 emissive = (_maintex_var.rgb*_Alpha_var.a*sin(((i.vertexColor.b*3.141592654)+node_2800.b))*0.5);
/// Final Color:
                float3 finalColor = diffuse + specular + emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
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
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _maintex; uniform float4 _maintex_ST;
            uniform sampler2D _Alpha; uniform float4 _Alpha_ST;
            uniform float _node_1662;
            uniform float _node_5164;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 vertexColor : COLOR;
                LIGHTING_COORDS(3,4)
                UNITY_FOG_COORDS(5)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                float gloss = 0.5;
                float specPow = exp2( gloss * 10.0 + 1.0 );
////// Specular:
                float NdotL = saturate(dot( normalDirection, lightDirection ));
                float3 specularColor = float3(_node_5164,_node_5164,_node_5164);
                float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow)*specularColor;
                float3 specular = directSpecular;
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                fixed4 _maintex_var = tex2D(_maintex,TRANSFORM_TEX(i.uv0, _maintex));
                float3 diffuseColor = (_maintex_var.rgb*_node_1662);
                float3 diffuse = directDiffuse * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse + specular;
                fixed4 finalRGBA = fixed4(finalColor * 1,0);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
