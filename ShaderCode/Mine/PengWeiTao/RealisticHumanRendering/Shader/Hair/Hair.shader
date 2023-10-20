Shader "RealHuman/Hair"
{
    Properties
    {
        [HDR]_Tint("Tint",Color)=(1,1,1,1)
        _BaseColorTex ("_BaseColor", 2D) = "white" {}
        _NormalScale("Normal Scale",Range(0,4)) =1
        _NormalTex ("_NormalTex", 2D) = "Bump" {}
        _AOTex ("_AOTex", 2D) = "white" {}
        
        _HairShiftTex ("_HairShiftTex", 2D) = "white" {}
        _HairShiftTexScale ("_HairShiftTexScale",Float) = 10

        _AlphaClip("_AlphaClip",Range(0,1)) =0.5
 
        [Space(10)]
        _NormalMapInteisty("Normal Map Inteisty",Range(0,1)) =1
        
        [Space(40)]
        [Header(Kajiaya)]
        _First_HairColor ("_First_HairColor",Color) = (1,1,1,1)
        _First_ShiftTangent("_First_ShiftTangent",Range(-1,1)) =0.5
        _First_AnisotropicPowerValue ("_First_AnisotropicPowerValue",Float) = 1
        _First_AnisotropicPowerScale ("_First_AnisotropicPowerScale",Float) = 1

        [Space(10)]
        _Second_HairColor ("_Second_HairColor",Color) = (1,1,1,1)
        _Second_ShiftTangent("_Second_ShiftTangent",Range(-1,1)) =0.5
        _Second_AnisotropicPowerValue ("_Second_AnisotropicPowerValue",Float) = 1
        _Second_AnisotropicPowerScale ("_Second_AnisotropicPowerScale",Float) = 1
        
        [Header(BackLight)]
        [Space(20)]
        [Toggle(ENABLE_BackLight_ON)] _EnableBackLight("Enable BackLight",Float) = 0
        _BackLightLerp("Back Light Lerp",Float) = 1
        _BackLightPow("Back Light Pow",Float) = 1
        _BackLightIntensity("Back Light Intensity",Float) = 1
        [HDR]_BakcLightColor("Back Light Color",Color)=(1,1,1,1)

        [Space(40)]
        [Header(Marschner)]
        [Toggle(ENABLE_MARSCHNER_ON)] _EnableMarschner("Enable Marschner Specular",Float) = 1
        _Area("Area",Range(0,1)) = 0 
        _Eccentric("Eccentric",Range(0,1)) = 0
        _BackLit("BackLit",Range(0,10)) = 1
        [Space(15)]
        _Marschner1Smoothness("Marschner1 Smoothness",Range(0,1)) = 0.8
        _Marschner1Intensity("Marschner1 Intensity",Float) = 0.8
        [Space(15)]
        _Marschner2Smoothness("Marschner2 Smoothness",Range(0,1)) = 0.8
        _Marschner2Intensity("Marschner2 Intensity",Float) = 0.8
        
        [Space(20)]
        _ShadowIntensity("Shadow Intensity",Range(0,1)) =0.2
        
        [Space(20)]
        [Toggle(ENABLE_SH_ON)]_EnableSH("Enable SH",Float) =0        
    }           
    
    SubShader
    {
        //URP中默认的渲染顺序关键字
        //"LightMode"
        //1.SRPDefaultUnlit
        //2.UniversalForward
        //3.UniversalForwardOnly
        
        Tags{"RenderType" = "Transparent" "Queue"="Transparent" "RenderPipeline" = "UniversalPipeline" }
        
        //OIT:Oreder Indepent Transparency
        //Depth Peeling  
        Pass
        {
            Tags {"LightMode" = "DepthPeelingPass" }
         
            ZWrite On
            ZTest LEqual
            Cull Off
            
            HLSLPROGRAM
            #pragma target 4.5

            #pragma vertex HairVertex
            #pragma fragment DepthPeelingPixel

            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _CLUSTERED_RENDERING

            #pragma multi_compile _ ENABLE_MARSCHNER_ON
            #pragma multi_compile _ ENABLE_SH_ON
            #include "HairInc.hlsl" 
                                    
            ENDHLSL
        }
        
        //ShadowCaster
        Pass
        {
            Tags
            {
                 "LightMode"="ShadowCaster"
            }
            Cull Off
            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex HairVertex
            #pragma fragment ShaderCasterFragment
            
            #define SHADOW_CASTER
            #include "HairInc.hlsl"
            ENDHLSL
        }
        
         //DepthOnly
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }

    }
//    FallBack "Diffuse" 
}