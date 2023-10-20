Shader "RealHuman/a_SkinSSSS"
{
    Properties
    {
        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)

         [Toggle] _EnableBaseMapEyeMask("Enable BaseMap Eye Mask", Float) = 0.0
        _RoughnessEye("Roughness(Eye)", Range(0.0, 1.0)) = 0.5
        _SpecIntensityEye("Spec Intensity(Eye)", Float) = 1
        
        [Space(20)]
        [Toggle(ENABLE_ROUGHNESS_MAP_ON)] EnableRoughnessMap("Enable Roughness Map",Float) = 0
        _RoughnessMap("Roughness",2D) = "Grey"{}
        _Roughness("Roughness(GGX Specular1)", Range(0.0, 1.0)) = 0.5
        _Roughness2("Roughness(GGX Specular2)", Range(0.0, 1.0)) = 0.5
        [Space(20)]
        
//        [Toggle(ENABLE_NORMAL_MAP_ON)] _EnableNormalMap("Enable Normal Map",Float) =1
        _BumpScale("Scale", Float) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {}

//        _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
//        _OcclusionMap("Occlusion", 2D) = "white" {}

        _DetailNormalMapScale("Detail NormalMap Scale", Range(0.0, 2.0)) = 1.0
        _DetailNormalMap("Detail Normal", 2D) = "bump" {}
        _DetailNormalMapInteisty("Detail Noram Intensity ", Range(0.0, 1.0)) = 1.0
        
        [Space(20)]
        [Header(Beckman Specular)]
        [Toggle(ENABLE_BECKMAN_ON)] _EnableBeckman("Enable Beckman",Float) = 0
        _BeckmanRoughness("Beckman Roughness", Range(0.0, 1.0)) = 0.5
        _BeckmanIntensity("Beckman Intensity", Range(0.0, 1.0)) = 0.5
    }

    SubShader
    {
        // Universal Pipeline tag is required. If Universal render pipeline is not set in the graphics settings
        // this Subshader will fail. One can add a subshader below or fallback to Standard built-in to make this
        // material work with both Universal Render Pipeline and Builtin Unity Pipeline
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "Lit" "IgnoreProjector" = "True" "ShaderModel"="4.5"
        }
        LOD 300

        // ------------------------------------------------------------------
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
//        Cull off

        Pass
        {
            
            Name "SkinSSS_Diffuse"
            Tags
            {
                "LightMode" = "SkinSSSS"
            }

            HLSLPROGRAM
            #pragma target 4.5

            #pragma vertex LitPassVertex
            #pragma fragment SkinSSSSFragment
            // #pragma fragment SkinFragmentMRT

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

            #pragma multi_compile _ DISABLE_SKIN_SH
            // #pragma shader_feature _ ENABLE_NORMAL_MAP_ON
            
            
            #define SKIN_SSSS_DIFFUSE
            #include "SkinSSSSCommon.hlsl"
            
            ENDHLSL
        }

        //ForwardLit
        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "SkinSpcular+SkinSSS"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM
            #pragma target 4.5


            #pragma vertex LitPassVertex
            #pragma fragment SkinSSSSFragment

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
            
            #pragma shader_feature _ ENABLE_ROUGHNESS_MAP_ON
            // #pragma shader_feature _ ENABLE_NORMAL_MAP_ON
            
            #pragma multi_compile _ DISABLE_SKIN_SH
            #pragma shader_feature _ ENABLE_BECKMAN_ON

            #define SKIN_SSSS_SPECULAR
            #include "SkinSSSSCommon.hlsl"
            
            ENDHLSL
            
        }

        //ShadowCaster
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // -------------------------------------
            // Universal Pipeline keywords

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        //DepthOnly 在SceneView窗口会跑
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

//    FallBack "Hidden/Universal Render Pipeline/FallbackError"
//    CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.LitShader"
}