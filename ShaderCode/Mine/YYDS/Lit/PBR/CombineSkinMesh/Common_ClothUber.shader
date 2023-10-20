Shader "TA/Lit/PBR/Common_ClothUber"
{
    Properties
    {
        // 纹理------------------------------------------------------------>
        [Foldout(1,2,0,0)]
        _FoldoutTextures("纹理_Foldout", float) = 1
        [Tex] [NoScaleOffset] _BaseMap("基础纹理", 2D) = "white" {}
        [Tex] [NoScaleOffset] _NormalMap("法线纹理", 2D) = "bump" {}
        [Tex] [NoScaleOffset] _EnvCube("环境Cube", Cube) = "black" {}
        [Tex] [NoScaleOffset] _MaskMap("遮罩纹理", 2D) = "black" {}
        [Foldout_Out(1)]
        _FoldoutOutTextures("纹理_Foldout", float) = 1
        // 纹理<------------------------------------------------------------

        // 选项------------------------------------------------------------>
        //[Header(Options)]
        [Foldout(1,2,0,0)]
        _FoldoutOptions("选项_Foldout", float) = 1
        [Toggle_Switch] _IsOpaque("是否为固体(否则为半透明)", float) = 1 // 固体/半透明
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("混合 源", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("混合 目标", Float) = 0
        [Enum(Off, 0, On, 1)] _ZWrite ("Z缓存写入", Float) = 1
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("剔除模式", Float) = 2

        [Toggle_Switch(_IsOpaque)] _Clip("剪裁", float) = 0
        [SwitchOr(_Clip)] _ClipValue("剪裁值", Range(0,1)) = 0.5

        [Foldout_Out(1)]
        _FoldoutOutOptions("选项_Foldout", float) = 1
        // 选项<------------------------------------------------------------

        // 特色功能------------------------------------------------------------>
        [Foldout(1,2,0,0)]
        _FoldoutFeatures("特色功能_Foldout", float) = 1

        // 金属
        [Header(Meta)]
        [Toggle_Switch] _Meta("是否有金属", float) = 0
        
        [Enum_Switch(enum_MaskByPass, enum_MaskByUV, _Meta)] _MetaMaskType("金属遮罩类型", float) = 0
        [SwitchOr(_Meta)] _MetaMaskPassIndex("金属遮罩通道索引", float) = 0
        [Range(_Meta, MaskByUV)] _MetaMaskURange("金属遮罩U坐标", Vector) = (0,1,0,1)
        [Range(_Meta, MaskByUV)] _MetaMaskVRange("金属遮罩V坐标", Vector) = (0,1,0,1)

        [SwitchOr(_Meta)] _MetaMetallic("金属金属度", Range(0,1)) = 1
        [SwitchOr(_Meta)] _MetaRoughness("金属粗糙度", Range(0,1)) = 0
        [SwitchOr(_Meta)] _MetaDiffIntensity("金属漫反射强度", float) = 1
        [SwitchOr(_Meta)] _MetaSpecIntensity("金属高光强度", float) = 1

        [Header(Meta2)]
        [Toggle_Switch] _Meta2("是否有金属二", float) = 0
        [SwitchOr(_Meta2)] _Meta2MaskPassIndex("金属二遮罩通道索引", float) = 0
        [SwitchOr(_Meta2)] _Meta2Metallic("金属二金属度", Range(0,1)) = 1
        [SwitchOr(_Meta2)] _Meta2Roughness("金属二粗糙度", Range(0,1)) = 0
        [SwitchOr(_Meta2)] _Meta2DiffIntensity("金属二漫反射强度", float) = 1
        [SwitchOr(_Meta2)] _Meta2SpecIntensity("金属二高光强度", float) = 1

        // 皮革
        [Header(Leather)]
        [Toggle_Switch] _Leather("是否有皮革", float) = 0
        [SwitchOr(_Leather)] _LeatherMaskPassIndex("皮革遮罩通道索引", float) = 0
        [SwitchOr(_Leather)] _LeatherRoughness("皮革粗糙度", Range(0,1)) = 0
        [SwitchOr(_Leather)] _LeatherDiffIntensity("皮革漫反射强度", float) = 1
        [SwitchOr(_Leather)] _LeatherSpecIntensity("皮革高光强度", float) = 1

        // 边缘光
        [Header(Fresnel)]
        [Toggle_Switch] _Fresnel("是否有边缘光", float) = 0
        [Enum_Switch(enum_Default, enum_MaskByPass, enum_MaskByUV, _Fresnel)] _FresnelMaskType("边缘光遮罩类型", float) = 0
        [SwitchAnd(_Fresnel, MaskByPass)] _FresnelMaskPassIndex("边缘光遮罩通道索引", float) = 0
        [Range(_Fresnel, MaskByUV)] _FresnelMaskURange("边缘光遮罩U坐标", Vector) = (0,1,0,1)
        [Range(_Fresnel, MaskByUV)] _FresnelMaskVRange("边缘光遮罩V坐标", Vector) = (0,1,0,1)
        [SwitchOr(_Fresnel)] _FresnelColor("边缘光颜色", Color) = (0,0,0,0)

        // 钻石
        [Header(Diamond1)]
        [Toggle_Switch] _Diamond1("是否有钻石一", float) = 0
        [SwitchOr(_Diamond1)] _Diamond1MaskPassIndex("钻石一遮罩通道索引", float) = 0
        [Toggle_Switch(_Diamond1)] _Diamond1SetColor("设定钻石一颜色", float) = 0
        [SwitchAnd(_Diamond1, _Diamond1SetColor)] _Diamond1Color("Diamond1 Color", Color) = (0,0,0,0)
        [Toggle_Switch(_Diamond1)] _ResetDiamond1Normal("重设钻石一法线", float) = 0
        [Toggle_Switch(_Diamond1)] _Diamond1NotClip("钻石一不裁剪", float) = 0

        [Header(Diamond2)]
        [Toggle_Switch] _Diamond2("是否有钻石二", float) = 0
        [SwitchOr(_Diamond2)] _Diamond2MaskPassIndex("钻石一遮罩通道索引", float) = 0
        [SwitchOr(_Diamond2)] _Diamond2Color("Diamond2 Color", Color) = (0,0,0,0)
        [Toggle_Switch(_Diamond2)] _ResetDiamond2Normal("重设钻石二法线", float) = 0

        // 宝石
        [Header(Gem)]
        [Toggle_Switch] _Gem("是否有宝石", float) = 0
        [SwitchOr(_Gem)] _GemMaskPassIndex("宝石遮罩通道索引", float) = 0
        [SwitchOr(_Gem)] _GemDiffIntensity("宝石漫反射强度", float) = 1
        [Toggle_Switch(_Gem)] _GemNotClip("宝石不裁剪", float) = 0

        // 珍珠
        [Header(Pearl)]
        [Toggle_Switch] _Pearl("是否有珍珠", float) = 0
        [Enum_Switch(enum_MaskByPass, enum_MaskByUV, _Pearl)] _PearlMaskType("珍珠遮罩类型", float) = 0
        [SwitchAnd(_Pearl, MaskByPass)] _PearlMaskPassIndex("珍珠遮罩通道索引", float) = 0
        [Range(_Pearl, MaskByUV)] _PearlMaskURange("珍珠遮罩U坐标", Vector) = (0,1,0,1)
        [Range(_Pearl, MaskByUV)] _PearlMaskVRange("珍珠遮罩V坐标", Vector) = (0,1,0,1)
        [SwitchOr(_Pearl)] _PearlMetallic("珍珠金属度", Range(0,1)) = 0
        [SwitchOr(_Pearl)] _PearlRoughness("珍珠粗糙度", Range(0,1)) = 0
        [SwitchOr(_Pearl)] _PearlDiffIntensity("珍珠漫反射强度", float) = 1
        [Toggle_Switch(_Pearl)] _SetPearlColor("是否设置珍珠颜色", float) = 0
        [SwitchAnd(_Pearl,_SetPearlColor)] _PearlColor("珍珠颜色", Color) = (0,0,0,0)

        // 半透明珍珠
        [Header(TransparentPearl)]
        [Toggle_Switch] _TransparentPearl("是否有半透明珍珠", float) = 0
        [Range(_TransparentPearl)] _TransparentPearlMaskURange("半透明珍珠遮罩U坐标", Vector) = (0,1,0,1)
        [SwitchOr(_TransparentPearl)] _TransparentPearlColor("半透明珍珠颜色", Color) = (0,0,0,0)

        // 闪烁效果
        [Header(Flake)]
        [Toggle_Switch] _Flake("是否有闪烁效果", float) = 0
        [Toggle_Switch(_Flake)] _SetFlakeColor("是否指定闪烁颜色(否则为随机颜色)", float) = 0
        [SwitchAnd(_Flake,_SetFlakeColor)] _FlakeColor("闪烁颜色", Color) = (1,1,1,1)
        [Toggle_Switch(_Flake)] _FlakeMask("是否指定闪烁遮罩", float) = 0
        [SwitchAnd(_Flake, _FlakeMask)] _FlakeMaskPassIndex("宝石遮罩通道索引", float) = 0
        [Tex(_Flake)] [NoScaleOffset] _FlakeNoiseMap("闪烁噪声图", 2D) = "black" {}
        [SwitchOr(_Flake)] _FlakeParam("闪烁参数(平铺,视线,流动,强度)", Vector) = (5,1,1,3)

        // 镭射
        [Header(Laser)]
        [Toggle_Switch] _Laser("是否有镭射效果", float) = 0
        [Toggle_Switch(_Laser)] _LaserMask("是否指定镭射遮罩", float) = 0
        [SwitchAnd(_Laser, _LaserMask)] _LaserMaskPassIndex("镭射遮罩通道索引", float) = 0
        [Tex(_Laser)] _LaserNoiseMap("Laser Noise Map", 2D) = "black" {}
        [SwitchOr(_Laser)] _LaserParam("Laser Param", Vector) = (0.4,0.2,0.5,1.3)
        [SwitchOr(_Laser)] _LaserNoiseSpeed("Laser Noise Speed", float) = 0.2
        [SwitchOr(_Laser)] _LaserNoiseScale("Laser Noise Scale", float) = 3

        // 星云图
        [Header(Cloud)]
        [Toggle_Switch] _Cloud("是否有星云效果", float) = 0
        [SwitchOr(_Cloud)] _CloudMaskPassIndex("星云遮罩通道索引", float) = 0
        [Tex(_Cloud)] [NoScaleOffset] _CloudMap("星云图", 2D) = "black" {}
		[SwitchOr(_Cloud)] _CloudMapIntensity ("星云图强度", float) = 1

        // 头发高光
        [Header(Hair)]
        [Toggle_Switch] _Hair("是否有头发高光", float) = 0
        [Range(_Hair)] _HairMaskURange("头发遮罩U坐标", Vector) = (0,1,0,1)
        [Range(_Hair)] _HairMaskVRange("头发遮罩V坐标", Vector) = (0,1,0,1)

        [SwitchOr(_Hair)] _HairRoughness("头发粗糙度", Range(0,1)) = 1
        [SwitchOr(_Hair)] _HairDiffIntensity("头发漫反射强度", float) = 1
        [SwitchOr(_Hair)] _HairSpecIntensity("头发高光强度", float) = 1

        [SwitchOr(_Hair)] _HairBaseColor("头发基础颜色", Color) = (1,1,1,1)
        [SwitchOr(_Hair)] _HairSpecColor("头发高光颜色", Color) = (0.5,0.5,0.5,0)
        [Tex(_Hair)] [NoScaleOffset] _ShiftMap("头发高光噪声图", 2D) = "black" {}
		[SwitchOr(_Hair)] _SpecShiftNoiseOffset("头发高光噪声偏移量", float) = -0.4

        // 细节贴图
        [Header(DetailMap)]
        [Toggle_Switch] _HasDetailMap("是否有细节贴图", float) = 0
        [SwitchOr(_HasDetailMap)] _DetailMapPassIndex("细节贴图遮罩通道索引", float) = 0
        [Tex(_HasDetailMap)] _DetailMap("细节贴图", 2D) = "black" {}

        // 马赛克闪烁效果
        [Header(MosaicFlake)]
        [Toggle_Switch] _MosaicFlake("是否有马赛克闪烁效果", float) = 0
        [Enum_Switch(enum_MosaicMaskByPass, enum_MosaicMaskByUV, _MosaicFlake)] _MosaicFlakeMaskType("马赛克闪烁遮罩类型", float) = 0
        [SwitchAnd(_MosaicFlake, MosaicMaskByPass)] _MosaicFlakeMaskPassIndex("马赛克闪烁遮罩通道索引", float) = 0
        [Range(_MosaicFlake, MosaicMaskByUV)] _MosaicFlakeMaskURange("马赛克闪烁遮罩U坐标", Vector) = (0,1,0,1)
        [Range(_MosaicFlake, MosaicMaskByUV)] _MosaicFlakeMaskVRange("马赛克闪烁遮罩V坐标", Vector) = (0,1,0,1)
        [SwitchOr(_MosaicFlake)] _MosaicFlakeNoiseTilling("马赛克闪烁平铺值", float) = 1
        [SwitchOr(_MosaicFlake)] _MosaicFlakeRoughness("马赛克闪烁粗糙度", Range(0,1)) = 1
        [SwitchOr(_MosaicFlake)] _MosaicFlakeMetallic("马赛克闪烁金属度", Range(0,1)) = 0

        // 马赛克闪烁效果二
        [Header(MosaicFlake2)]
        [Toggle_Switch] _MosaicFlake2("是否有马赛克闪烁效果二", float) = 0
        [SwitchAnd(_MosaicFlake2)] _MosaicFlake2BaseColor("马赛克闪烁二基础颜色", Color) = (1,1,1,1)
        [SwitchAnd(_MosaicFlake2)] _MosaicFlake2Color("马赛克闪烁二颜色", Color) = (1,1,1,1)
        [Range(_MosaicFlake2)] _MosaicFlake2MaskURange("马赛克闪烁二遮罩U坐标", Vector) = (0,1,0,1)
        [Range(_MosaicFlake2)] _MosaicFlake2MaskVRange("马赛克闪烁二遮罩V坐标", Vector) = (0,1,0,1)
        [SwitchOr(_MosaicFlake2)] _MosaicFlake2NoiseTilling("马赛克闪烁二平铺值", float) = 1
        [SwitchOr(_MosaicFlake2)] _MosaicFlake2Roughness("马赛克闪烁二粗糙度", Range(0,1)) = 1
        [Tex(_MosaicFlake, _MosaicFlake2)] [NoScaleOffset] _MosaicFlakeNoiseMap("马赛克闪烁噪声图", 2D) = "black" {}

        // 水雾流动效果
        [Header(FlowWaterFog)]
        [Toggle_Switch] _FlowWaterFog("是否有水雾流动效果", float) = 0
        [SwitchAnd(_FlowWaterFog)] _FlowWaterFogPassIndex("水雾流动效果遮罩通道索引", float) = 0
        [SwitchAnd(_FlowWaterFog)] _FlowWaterFogColor("水雾流动效果颜色", Color) = (1,1,1,1)
        [Tex(_FlowWaterFog)] _FlowWaterFogNoiseMap("水雾流动效果噪声图", 2D) = "black" {}
        [SwitchAnd(_FlowWaterFog)] _FlowWaterFogNDisturbIntensity("水雾流动法线扰动强度", float) = 1
        [SwitchAnd(_FlowWaterFog)] _FlowWaterFogIntensity("水雾流动效果强度", float) = 1

        [Foldout_Out(1)]
        _FoldoutOutFeatures("特色功能_Foldout", float) = 1
        // 特色功能<------------------------------------------------------------

        // 默认设置------------------------------------------------------------>
        //[Header(Default)]
        [Foldout(1,2,0,0)]
        _FoldoutDefault("默认设置_Foldout", float) = 1
        _SpendColor("混合颜色", Color) = (1,1,1,1)
        _DefaultMetallic("默认金属度", Range(0,1)) = 0
        _DefaultRoughness("默认粗糙度", Range(0,1)) = 1
        _DefaultDiffIntensity("默认漫反射强度", float) = 1
        _DefaultSpecIntensity("默认高光强度", float) = 1
        _HalfLambertIntensity("半兰伯特强度", Range(0,1)) = 0.5
        [Toggle_Switch] _FixErrorNormal("是否修复错误法线", float) = 0
        [Toggle_Switch] _DebugMode("是否是调试模式", float) = 0
        [Foldout_Out(1)]
        _FoldoutOutDefault("默认设置_Foldout", float) = 1
        // 默认设置<------------------------------------------------------------
    }


    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 500

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            Cull [_Cull]

            HLSLPROGRAM

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _DEBUGMODE_ON
            #pragma shader_feature_local_fragment _CLIP_ON
            // 金属
            #pragma shader_feature_local_fragment _META_ON
            #pragma shader_feature_local_fragment _METAMASKTYPE_MASKBYPASS
            #pragma shader_feature_local_fragment _METAMASKTYPE_MASKBYUV
            #pragma shader_feature_local_fragment _META2_ON
            // 皮革
            #pragma shader_feature_local_fragment _LEATHER_ON
            // 边缘光
            #pragma shader_feature_local_fragment _FRESNEL_ON
            #pragma shader_feature_local_fragment _FRESNELMASKTYPE_DEFAULT
            #pragma shader_feature_local_fragment _FRESNELMASKTYPE_MASKBYPASS
            #pragma shader_feature_local_fragment _FRESNELMASKTYPE_MASKBYUV
            #pragma shader_feature_local_fragment _DIAMOND1NOTCLIP_ON
            // 钻石
            #pragma shader_feature_local_fragment _DIAMOND1_ON
            #pragma shader_feature_local_fragment _DIAMOND1SETCOLOR_ON
            #pragma shader_feature_local_fragment _RESETDIAMOND1NORMAL_ON
            #pragma shader_feature_local_fragment _DIAMOND2_ON
            #pragma shader_feature_local_fragment _RESETDIAMOND2NORMAL_ON
            // 宝石
            #pragma shader_feature_local_fragment _GEM_ON
            // 珍珠
            #pragma shader_feature_local_fragment _PEARL_ON
            #pragma shader_feature_local_fragment _SETPEARLCOLOR_ON
            // 半透明珍珠
            #pragma shader_feature_local_fragment _TRANSPARENTPEARL_ON
            #pragma shader_feature_local_fragment _PEARLMASKTYPE_MASKBYPASS
            #pragma shader_feature_local_fragment _PEARLMASKTYPE_MASKBYUV
            #pragma shader_feature_local_fragment _GEMNOTCLIP_ON
            // 闪烁效果
            #pragma shader_feature_local_fragment _FLAKE_ON
            #pragma shader_feature_local_fragment _SETFLAKECOLOR_ON
            #pragma shader_feature_local_fragment _FLAKEMASK_ON
            // 镭射
            #pragma shader_feature_local_fragment _LASER_ON
            #pragma shader_feature_local_fragment _LASERMASK_ON
            // 星云图
            #pragma shader_feature_local_fragment _CLOUD_ON
            #pragma shader_feature_local_fragment _ISOPAQUE_ON
            // 头发高光
            #pragma shader_feature_local_fragment _HAIR_ON
            #pragma shader_feature_local_fragment _FIXERRORNORMAL_ON
            // 细节贴图
            #pragma shader_feature_local_fragment _HASDETAILMAP_ON
            // 马赛克闪烁效果
            #pragma shader_feature_local_fragment _MOSAICFLAKE_ON
            #pragma shader_feature_local_fragment _MOSAICFLAKEMASKTYPE_MOSAICMASKBYPASS
            #pragma shader_feature_local_fragment _MOSAICFLAKEMASKTYPE_MOSAICMASKBYUV
            #pragma shader_feature_local_fragment _MOSAICFLAKE2_ON
            #pragma shader_feature_local_fragment _MOSAICFLAKE2MASKTYPE_MOSAIC2MASKBYUV
            // 水雾流动效果
            #pragma shader_feature_local_fragment _FLOWWATERFOG_ON

            // -------------------------------------
            // Universal Pipeline keywords
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            //#pragma multi_compile_fragment _ _SHADOWS_SOFT
            //#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "BRDF_Cloth.hlsl"

            // 纹理
            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
            TEXTURECUBE(_EnvCube); SAMPLER(sampler_EnvCube);
            TEXTURE2D(_MaskMap); SAMPLER(sampler_MaskMap);

            // 闪烁效果
            #if _FLAKE_ON
                TEXTURE2D(_FlakeNoiseMap); SAMPLER(sampler_FlakeNoiseMap);
            #endif

            // 镭射
            #if _LASER_ON
                TEXTURE2D(_LaserNoiseMap); SAMPLER(sampler_LaserNoiseMap);
            #endif

            // 星云图
            #if _CLOUD_ON
                TEXTURE2D(_CloudMap); SAMPLER(sampler_CloudMap);
            #endif

            // 头发高光
            #if _HAIR_ON
                TEXTURE2D(_ShiftMap); SAMPLER(sampler_ShiftMap);
            #endif

            // 细节贴图
            #if _HASDETAILMAP_ON
                TEXTURE2D(_DetailMap); SAMPLER(sampler_DetailMap);
            #endif

            // 马赛克闪烁效果
            #if _MOSAICFLAKE_ON || _MOSAICFLAKE2_ON
                TEXTURE2D(_MosaicFlakeNoiseMap); SAMPLER(sampler_MosaicFlakeNoiseMap);
            #endif

            // 水雾流动效果
            #if _FLOWWATERFOG_ON
                TEXTURE2D(_FlowWaterFogNoiseMap); SAMPLER(sampler_FlowWaterFogNoiseMap);
            #endif


            CBUFFER_START(UnityPerMaterial)
            half4 _EnvCube_HDR;

            // 剪裁
            #if _CLIP_ON
                half _ClipValue;
            #endif

            // 金属
            #if _META_ON
                #if _METAMASKTYPE_MASKBYPASS
                    half _MetaMaskPassIndex;
                #elif _METAMASKTYPE_MASKBYUV
                    half4 _MetaMaskURange;
                    half4 _MetaMaskVRange;
                #endif
                half _MetaMetallic;
                half _MetaRoughness;
                half _MetaDiffIntensity;
                half _MetaSpecIntensity;
            #endif

            #if _META2_ON
                half _Meta2MaskPassIndex;
                half _Meta2Metallic;
                half _Meta2Roughness;
                half _Meta2DiffIntensity;
                half _Meta2SpecIntensity;
            #endif

            // 皮革
            #if _LEATHER_ON
                half _LeatherMaskPassIndex;
                half _LeatherRoughness;
                half _LeatherDiffIntensity;
                half _LeatherSpecIntensity;
            #endif

            // 边缘光
            #if _FRESNEL_ON
                #if _FRESNELMASKTYPE_MASKBYPASS
                    half _FresnelMaskPassIndex;
                #endif
                #if _FRESNELMASKTYPE_MASKBYUV
                    half4 _FresnelMaskURange;
                    half4 _FresnelMaskVRange;
                #endif
                half4 _FresnelColor;
            #endif

            // 钻石
            #if _DIAMOND1_ON
                half _Diamond1MaskPassIndex;
                #if _DIAMOND1SETCOLOR_ON
                    half4 _Diamond1Color;
                #endif
            #endif
            #if _DIAMOND2_ON
                half _Diamond2MaskPassIndex;
                half4 _Diamond2Color;
            #endif

            // 宝石
            #if _GEM_ON
                half _GemMaskPassIndex;
                half _GemDiffIntensity;
            #endif

            // 珍珠
            #if _PEARL_ON
                #if _PEARLMASKTYPE_MASKBYPASS
                    half _PearlMaskPassIndex;
                #elif _PEARLMASKTYPE_MASKBYUV
                    half4 _PearlMaskURange;
                    half4 _PearlMaskVRange;
                #endif
                half _PearlMetallic;
                half _PearlRoughness;
                half _PearlDiffIntensity;
                #if _SETPEARLCOLOR_ON
                    half4 _PearlColor;
                #endif
            #endif

            // 半透明珍珠
            #if _TRANSPARENTPEARL_ON
                half4 _TransparentPearlMaskURange;
                half4 _TransparentPearlColor;
            #endif

            // 闪烁效果
            #if _FLAKE_ON
                #if _SETFLAKECOLOR_ON
                    half4 _FlakeColor;
                #endif
                #if _FLAKEMASK_ON
                    half _FlakeMaskPassIndex;
                #endif
                half4 _FlakeParam;
            #endif

            // 镭射
            #if _LASER_ON
                #if _LASERMASK_ON
                    half _LaserMaskPassIndex;
                #endif
                half4 _LaserNoiseMap_ST;
                half4 _LaserParam;
                half _LaserNoiseSpeed;
                half _LaserNoiseScale;
            #endif

            // 星云图
            #if _CLOUD_ON
                half _CloudMaskPassIndex;
                half _CloudMapIntensity;
            #endif

            // 头发高光
            #if _HAIR_ON
                half4 _HairMaskURange;
                half4 _HairMaskVRange;
                half _HairRoughness;
                half _HairDiffIntensity;
                half _HairSpecIntensity;
                half4 _HairBaseColor;
                half4 _HairSpecColor;
                half _SpecShiftNoiseOffset;
            #endif

            // 细节贴图
            #if _HASDETAILMAP_ON
                half _DetailMapPassIndex;
                half4 _DetailMap_ST;
            #endif

            // 马赛克闪烁效果
            #if _MOSAICFLAKE_ON
                #if _MOSAICFLAKEMASKTYPE_MOSAICMASKBYPASS
                    half _MosaicFlakeMaskPassIndex;
                #elif _MOSAICFLAKEMASKTYPE_MOSAICMASKBYUV
                    half4 _MosaicFlakeMaskURange;
                    half4 _MosaicFlakeMaskVRange;
                #endif
                half _MosaicFlakeNoiseTilling;
                half _MosaicFlakeRoughness;
                half _MosaicFlakeMetallic;
            #endif

            #if _MOSAICFLAKE2_ON
                half4 _MosaicFlake2BaseColor;
                half4 _MosaicFlake2Color;
                half4 _MosaicFlake2MaskURange;
                half4 _MosaicFlake2MaskVRange;
                half _MosaicFlake2NoiseTilling;
                half _MosaicFlake2Roughness;
            #endif

            // 水雾流动效果
            #if _FLOWWATERFOG_ON
                half _FlowWaterFogPassIndex;
                half4 _FlowWaterFogNoiseMap_ST;
                half4 _FlowWaterFogColor;
                half _FlowWaterFogNDisturbIntensity;
                half _FlowWaterFogIntensity;
            #endif

            // 设置
            half4 _SpendColor;
            half _DefaultMetallic;
            half _DefaultRoughness;
            half _DefaultDiffIntensity;
            half _DefaultSpecIntensity;

            half _HalfLambertIntensity;
			CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 tangentOS : TANGENT;
                float3 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 tangentWS : TEXCOORD1;
                float4 bitangentWS : TEXCOORD2;
                float4 normalWS : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


            Varyings Vertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(positionWS);
                
                output.uv = input.texcoord;

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.tangentWS = float4(normalInput.tangentWS, positionWS.x);
                output.bitangentWS = float4(normalInput.bitangentWS, positionWS.y);
                output.normalWS = float4(normalInput.normalWS, positionWS.z);

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target
            {
                half3 debugCol;

                UNITY_SETUP_INSTANCE_ID(input);

                // TBN
                float3 tangentWS = input.tangentWS.xyz;
                float3 bitangentWS = input.bitangentWS.xyz;
                float3 normalWS = input.normalWS.xyz;
                float3 positionWS = float3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
                float3x3 TBN = float3x3(tangentWS, bitangentWS, normalWS);

                // 光照数据
                half3 V = GetWorldSpaceNormalizeViewDir(positionWS);
                Light mainLight = GetMainLight_ta(positionWS);

                // 采样
                half2 uv = input.uv;
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                half4 maskMap = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv);
                half alpha = baseMap.a;

                // 遮罩
                half maskCloth = 1;
                #if _META_ON
                    half maskMeta = 0;
                    #if _METAMASKTYPE_MASKBYPASS
                        maskMeta = maskMap[_MetaMaskPassIndex];
                    #elif _METAMASKTYPE_MASKBYUV
                        maskMeta = min(step(_MetaMaskURange.x, uv.x), step(uv.x, _MetaMaskURange.y));
                        maskMeta = min(maskMeta, step(_MetaMaskVRange.x, uv.y));
                        maskMeta = min(maskMeta, step(uv.y, _MetaMaskVRange.y));
                    #endif
                    maskCloth = min(maskCloth, 1 - maskMeta);
                #endif
                #if _META2_ON
                    half maskMeta2 = maskMap[_Meta2MaskPassIndex];
                    maskCloth = min(maskCloth, 1 - maskMeta2);
                #endif
                #if _LEATHER_ON
                    half maskLeather = maskMap[_LeatherMaskPassIndex];
                    maskCloth = min(maskCloth, 1 - maskLeather);
                #endif
                #if _DIAMOND1_ON
                    half maskDiamond1 = maskMap[_Diamond1MaskPassIndex];
                    maskCloth = min(maskCloth, 1 - maskDiamond1);
                    #if _DIAMOND1NOTCLIP_ON
                        alpha = lerp(alpha, 1, maskDiamond1);
                    #endif
                #endif
                #if _DIAMOND2_ON
                    half maskDiamond2 = maskMap[_Diamond2MaskPassIndex];
                    maskCloth = min(maskCloth, 1 - maskDiamond2);
                #endif
                #if _GEM_ON
                    half maskGem = maskMap[_GemMaskPassIndex];
                    maskCloth = min(maskCloth, 1 - maskGem);
                    #if _GEMNOTCLIP_ON
                        alpha = lerp(alpha, 1, maskGem);
                    #endif
                #endif
                #if _PEARL_ON
                    half maskPearl;
                    #if _PEARLMASKTYPE_MASKBYPASS
                        maskPearl = maskMap[_PearlMaskPassIndex];
                    #elif _PEARLMASKTYPE_MASKBYUV
                        maskPearl = min(step(_PearlMaskURange.x, uv.x), step(uv.x, _PearlMaskURange.y));
                        maskPearl = min(maskPearl, step(_PearlMaskVRange.x, uv.y));
                        maskPearl = min(maskPearl, step(uv.y, _PearlMaskVRange.y));
                    #endif
                    maskCloth = min(maskCloth, 1 - maskPearl);
                #endif
                #if _TRANSPARENTPEARL_ON
                    half maskTransparentPearl = min(step(_TransparentPearlMaskURange.x, uv.x), step(uv.x, _TransparentPearlMaskURange.y));
                    maskCloth = min(maskCloth, 1 - maskTransparentPearl);
                #endif
                #if _HAIR_ON
                    half maskHair = min(step(_HairMaskURange.x, uv.x), step(uv.x, _HairMaskURange.y));
                    maskHair = min(maskHair, step(_HairMaskVRange.x, uv.y));
                    maskHair = min(maskHair, step(uv.y, _HairMaskVRange.y));
                    maskCloth = min(maskCloth, 1 - maskHair);
                #endif
                #if _MOSAICFLAKE_ON
                    half maskMosaicFlake = 0;
                    #if _MOSAICFLAKEMASKTYPE_MOSAICMASKBYPASS
                        maskMosaicFlake = maskMap[_MosaicFlakeMaskPassIndex];
                    #elif _MOSAICFLAKEMASKTYPE_MOSAICMASKBYUV
                        maskMosaicFlake = min(step(_MosaicFlakeMaskURange.x, uv.x), step(uv.x, _MosaicFlakeMaskURange.y));
                        maskMosaicFlake = min(maskMosaicFlake, step(_MosaicFlakeMaskVRange.x, uv.y));
                        maskMosaicFlake = min(maskMosaicFlake, step(uv.y, _MosaicFlakeMaskVRange.y));
                    #endif
                    alpha = lerp(alpha, 1, maskMosaicFlake);
                #endif
                #if _MOSAICFLAKE2_ON
                    half maskMosaicFlake2 = min(step(_MosaicFlake2MaskURange.x, uv.x), step(uv.x, _MosaicFlake2MaskURange.y));
                    maskMosaicFlake2 = min(maskMosaicFlake2, step(_MosaicFlake2MaskVRange.x, uv.y));
                    maskMosaicFlake2 = min(maskMosaicFlake2, step(uv.y, _MosaicFlake2MaskVRange.y));
                #endif

                // 剪裁
                #if _ISOPAQUE_ON && _CLIP_ON
                    clip(alpha - _ClipValue);
                #endif

                // 漫反射强度
                half diffuseIntensity = _DefaultDiffIntensity;
                #if _META_ON
                    diffuseIntensity = lerp(diffuseIntensity, _MetaDiffIntensity, maskMeta);
                #endif
                #if _META2_ON
                    diffuseIntensity = lerp(diffuseIntensity, _Meta2DiffIntensity, maskMeta2);
                #endif
                #if _LEATHER_ON
                    diffuseIntensity = lerp(diffuseIntensity, _LeatherDiffIntensity, maskLeather);
                #endif
                #if _GEM_ON
                    diffuseIntensity = lerp(diffuseIntensity, _GemDiffIntensity, maskGem);
                #endif
                #if _PEARL_ON
                    diffuseIntensity = lerp(diffuseIntensity, _PearlDiffIntensity, maskPearl);
                #endif
                #if _HAIR_ON
                    diffuseIntensity = lerp(diffuseIntensity, _HairDiffIntensity, maskHair);
                #endif

                // 基本色
                half3 baseColor = baseMap.rgb * diffuseIntensity;
                #if _TRANSPARENTPEARL_ON
                    baseColor = lerp(baseColor, _TransparentPearlColor.rgb, maskTransparentPearl);
                #endif
                #if _HAIR_ON
                    baseColor = lerp(baseColor, baseColor * _HairBaseColor.rgb, maskHair);
                #endif
                #if _PEARL_ON && _SETPEARLCOLOR_ON
                    baseColor = lerp(baseColor, _PearlColor.rgb, maskPearl);
                #endif
                baseColor = lerp(baseColor, baseColor * _SpendColor.rgb, maskCloth);

                // 钻石
                #if _DIAMOND1_ON && _DIAMOND1SETCOLOR_ON
                    baseColor = lerp(baseColor, _Diamond1Color.rgb, maskDiamond1);
                #endif
                #if _DIAMOND2_ON
                    baseColor = lerp(baseColor, _Diamond2Color.rgb, maskDiamond2);
                #endif

                // 星云图
                #if _CLOUD_ON
                    half cloudMask = maskMap[_CloudMaskPassIndex];
                    half2 uv_cloudMap = uv * 10 + V.xy;
                    uv_cloudMap.x += _Time.x;
	                half4 cloudMap = SAMPLE_TEXTURE2D(_CloudMap, sampler_CloudMap, uv_cloudMap);
                    half3 cloudColor = cloudMap.rgb * cloudMask * _CloudMapIntensity;
                    baseColor += cloudColor;
                #endif

                // 细节贴图
                #if _HASDETAILMAP_ON
                    half maskDetailMap = maskMap[_DetailMapPassIndex];
                    half4 detailMap = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap, uv * _DetailMap_ST.xy + _DetailMap_ST.zw);
                    baseColor = lerp(baseColor, detailMap.rgb, maskDetailMap);
                #endif

                // 马赛克闪烁
                #if _MOSAICFLAKE2_ON
                    baseColor = lerp(baseColor, _MosaicFlake2BaseColor, maskMosaicFlake2);
                #endif

                // 法线
                half4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv);
                half3 tangentNormal = UnpackNormal(normalMap);
                half3 N = TransformTangentToWorld(tangentNormal, TBN);

                // 重设法线
                #if _DIAMOND1_ON && _RESETDIAMOND1NORMAL_ON
                    N = lerp(N, normalWS, maskDiamond1);
                #endif
                #if _DIAMOND2_ON && _RESETDIAMOND2NORMAL_ON
                    N = lerp(N, normalWS, maskDiamond2);
                #endif

                half NoV = saturate(abs(dot(N, V))+1e-5);

                // 透明度
                #if _TRANSPARENTPEARL_ON
                    alpha = lerp(alpha, 1-NoV, maskTransparentPearl);
                #endif

                // 粗糙度
                half roughness = _DefaultRoughness;
                #if _META_ON
                    roughness = lerp(roughness, _MetaRoughness, maskMeta);
                #endif
                #if _META2_ON
                    roughness = lerp(roughness, _Meta2Roughness, maskMeta2);
                #endif
                #if _LEATHER_ON
                    roughness = lerp(roughness, _LeatherRoughness, maskLeather);
                #endif
                #if _DIAMOND1_ON
                    roughness = lerp(roughness, 0, maskDiamond1);
                #endif
                #if _DIAMOND2_ON
                    roughness = lerp(roughness, 0, maskDiamond2);
                #endif
                #if _PEARL_ON
                    roughness = lerp(roughness, _PearlRoughness, maskPearl);
                #endif
                #if _GEM_ON
                    roughness = lerp(roughness, 0, maskGem);
                #endif
                #if _HAIR_ON
                    roughness = lerp(roughness, _HairRoughness, maskHair);
                #endif
                #if _MOSAICFLAKE_ON
                    roughness = lerp(roughness, _MosaicFlakeRoughness, maskMosaicFlake);
                #endif
                #if _MOSAICFLAKE2_ON
                    roughness = lerp(roughness, _MosaicFlake2Roughness, maskMosaicFlake2);
                #endif
                roughness = max(0.05, roughness);

                // 高光强度
                half specIntensity = _DefaultSpecIntensity;
                #if _META_ON
                    specIntensity = lerp(specIntensity, _MetaSpecIntensity, maskMeta);
                #endif
                #if _META2_ON
                    specIntensity = lerp(specIntensity, _Meta2SpecIntensity, maskMeta2);
                #endif
                #if _LEATHER_ON
                    specIntensity = lerp(specIntensity, _LeatherSpecIntensity, maskLeather);
                #endif
                #if _HAIR_ON
                    specIntensity = lerp(specIntensity, _HairSpecIntensity, maskHair);
                #endif

                // 金属度
                half metallic = _DefaultMetallic;
                #if _META_ON
                    metallic = lerp(metallic, _MetaMetallic, maskMeta);
                #endif
                #if _META2_ON
                    metallic = lerp(metallic, _Meta2Metallic, maskMeta2);
                #endif
                #if _PEARL_ON
                    metallic = lerp(metallic, _PearlMetallic, maskPearl);
                #endif
                #if _MOSAICFLAKE_ON
                    metallic = lerp(metallic, _MosaicFlakeMetallic, maskMosaicFlake);
                #endif

                // 金属工作流，从 base map 中解码漫反射颜色与高光颜色
                half3 diffCol = baseColor * (1 - metallic);
                half3 specCol = lerp(0.04.xxx, baseColor.rgb, metallic) * specIntensity;
                half3 finalColor = half3(0, 0, 0);

                // 镭射
                #if _LASER_ON
                    half maskLaser = 1;
                    #if _LASERMASK_ON
                        maskLaser = maskMap[_LaserMaskPassIndex];
                    #endif
                    half2 uv_laserNoise = input.uv * _LaserNoiseMap_ST.xy;
                    uv_laserNoise += V.xy * _LaserNoiseSpeed;
                    half4 laserNoiseMap = SAMPLE_TEXTURE2D(_LaserNoiseMap, sampler_LaserNoiseMap, uv_laserNoise);
                    half fresnel = 1 - NoV + laserNoiseMap.r * _LaserNoiseScale;
                    half3 laserColor = CalcLaserColor(fresnel, _LaserParam) * diffCol;
                    diffCol = lerp(diffCol, laserColor, maskLaser);
                #endif

                // 马赛克闪烁
                #if _MOSAICFLAKE_ON || _MOSAICFLAKE2_ON
                    half mosaicFlakeNoiseTilling = 1;
                    half3 mosaicFlakeColor = half3(0,0,0);
                    half maskMosaicFlakeValue = 0;
                    #if _MOSAICFLAKE_ON
                        mosaicFlakeNoiseTilling = lerp(mosaicFlakeNoiseTilling, _MosaicFlakeNoiseTilling, maskMosaicFlake);
                        mosaicFlakeColor = baseColor.rgb;
                        maskMosaicFlakeValue = lerp(maskMosaicFlakeValue, 1, maskMosaicFlake);
                    #endif
                    #if _MOSAICFLAKE2_ON
                        mosaicFlakeNoiseTilling = lerp(mosaicFlakeNoiseTilling, _MosaicFlake2NoiseTilling, maskMosaicFlake2);
                        mosaicFlakeColor = lerp(mosaicFlakeColor, _MosaicFlake2Color.rgb, maskMosaicFlake2);
                        maskMosaicFlakeValue = lerp(maskMosaicFlakeValue, 1, maskMosaicFlake2);
                    #endif

                    half2 uv_MosaicFlakeNoise = floor(uv * mosaicFlakeNoiseTilling) * 0.1;
                    uv_MosaicFlakeNoise.x -= _Time.x * 0.3;
                    half4 mosaicFlakeNoiseMap = SAMPLE_TEXTURE2D(_MosaicFlakeNoiseMap, sampler_MosaicFlakeNoiseMap, uv_MosaicFlakeNoise);
                    half3 finalMosaicFlakeCol = mosaicFlakeColor * mosaicFlakeNoiseMap.r * maskMosaicFlakeValue;
                    diffCol += finalMosaicFlakeCol;
                #endif

                // 水雾流动效果
                #if _FLOWWATERFOG_ON
                    half maskFlowWaterFog = maskMap[_FlowWaterFogPassIndex];
                    half2 uv_FlowWaterFog = uv * _FlowWaterFogNoiseMap_ST.xy + _Time.xx * _FlowWaterFogNoiseMap_ST.zw + N.xy * _FlowWaterFogNDisturbIntensity;
                    half4 flowWaterFogNoiseMap = SAMPLE_TEXTURE2D(_FlowWaterFogNoiseMap, sampler_FlowWaterFogNoiseMap, uv_FlowWaterFog);
                    half3 finalFlowWaterFog = flowWaterFogNoiseMap.r * _FlowWaterFogColor.rgb * maskFlowWaterFog * _FlowWaterFogIntensity;
                    diffCol += finalFlowWaterFog;
                #endif

                // 漫反射
                half3 L = mainLight.direction;
                half3 radiance;
                half halfLambert;
                half3 diffuseLighting = half3(0,0,0);
                #if _FIXERRORNORMAL_ON
                    diffuseLighting = BRDF_HarfLambertLighting_FixN(mainLight, diffCol, N, V, _HalfLambertIntensity, radiance, halfLambert);
                #else
                    diffuseLighting = BRDF_HarfLambertLighting(mainLight, diffCol, N, V, _HalfLambertIntensity, radiance, halfLambert);
                #endif
                finalColor += diffuseLighting;

                // 镜面反射
                half3 specLighting = BRDF_StandardSpecularLighting(specCol, N, V, L, NoV, halfLambert, roughness, radiance);
                finalColor += specLighting;

                // 环境光
                half specDFGIntensity = 0;
                #if _DIAMOND1_ON
                    specDFGIntensity = lerp(specDFGIntensity, 1, maskDiamond1);
                #endif
                #if _DIAMOND2_ON
                    specDFGIntensity = lerp(specDFGIntensity, 1, maskDiamond2);
                #endif
                #if _PEARL_ON
                    specDFGIntensity = lerp(specDFGIntensity, 1, maskPearl);
                #endif
                half3 indirectLighting = IndirectLighting_Custom(diffCol, specCol, N, V, NoV, roughness, _EnvCube, sampler_EnvCube, _EnvCube_HDR, specDFGIntensity);
                finalColor += indirectLighting;

                // 菲涅尔
                #if _FRESNEL_ON
                    half maskFresnel = 1;
                    #if _FRESNELMASKTYPE_DEFAULT
                        maskFresnel = maskCloth;
                    #elif _FRESNELMASKTYPE_MASKBYPASS
                        maskFresnel = maskMap[_FresnelMaskPassIndex];
                    #elif _FRESNELMASKTYPE_MASKBYUV
                        maskFresnel = min(step(_FresnelMaskURange.x, uv.x), step(uv.x, _FresnelMaskURange.y));
                        maskFresnel = min(maskFresnel, step(_FresnelMaskVRange.x, uv.y));
                        maskFresnel = min(maskFresnel, step(uv.y, _FresnelMaskVRange.y));
                    #endif
                    half3 finalFresnelCol = CalcFresnelColor(_FresnelColor.rgb, NoV);
                    finalColor += finalFresnelCol * maskFresnel;
                #endif

                // 闪烁效果
                #if _FLAKE_ON
                    half3 flakeCol;
                    #if _SETFLAKECOLOR_ON
                        flakeCol = CalcFlakeColorPow2(_FlakeColor.rgb, _FlakeNoiseMap, sampler_FlakeNoiseMap, V, uv, _FlakeParam);
                    #else
                        flakeCol = CalcFlakeRandomColor(_FlakeNoiseMap, sampler_FlakeNoiseMap, V, NoV, uv, _FlakeParam);
                    #endif
                    half maskFlake = maskCloth;
                    #if _FLAKEMASK_ON
                        maskFlake = maskMap[_FlakeMaskPassIndex];
                    #endif
                    finalColor += flakeCol * maskFlake;
                #endif

                // 头发高光
                #if _HAIR_ON
                    half2 uv_hairNoise = uv * half2(10, 1);
                    half3 specHair = SpecularLighting_HairWithNoise(_HairSpecColor.rgb, _ShiftMap, sampler_ShiftMap, uv_hairNoise, _SpecShiftNoiseOffset, bitangentWS, N, V, halfLambert);
                    finalColor += specHair * maskHair;
                #endif

                #if _DEBUGMODE_ON
                    debugCol = maskMap.rgb;
                    finalColor = debugCol;
                #endif

                finalColor = saturate(finalColor);
				return float4(finalColor, alpha);
            }
            
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ColorMask 0

            HLSLPROGRAM
            #pragma target 3.0

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            float3 _LightDirection;
            float3 _LightPosition;

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv           : TEXCOORD0;
                float4 positionCS   : SV_POSITION;
            };

            float4 GetShadowPositionHClip(Attributes input)
            {
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

            #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                float3 lightDirectionWS = normalize(_LightPosition - positionWS);
            #else
                float3 lightDirectionWS = _LightDirection;
            #endif

                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

            #if UNITY_REVERSED_Z
                positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
            #else
                positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
            #endif

                return positionCS;
            }

            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);

                output.uv = input.texcoord;
                output.positionCS = GetShadowPositionHClip(input);
                return output;
            }

            half4 ShadowPassFragment(Varyings input) : SV_TARGET
            {
                return 0;
            }

            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ColorMask 0

            HLSLPROGRAM
            #pragma target 3.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 position     : POSITION;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv           : TEXCOORD0;
                float4 positionCS   : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings DepthOnlyVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);

                output.uv = input.texcoord;
                output.positionCS = TransformObjectToHClip(input.position.xyz);
                return output;
            }

            half4 DepthOnlyFragment(Varyings input) : SV_TARGET
            {
                return 0;
            }

            ENDHLSL
        }

        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            HLSLPROGRAM
            #pragma target 3.0

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 tangentOS : TANGENT;
                float3 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 tangentWS : TEXCOORD1;
                float4 bitangentWS : TEXCOORD3;
                float4 normalWS : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


            Varyings DepthNormalsVertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(positionWS);
                
                output.uv = input.texcoord;

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.tangentWS = float4(normalInput.tangentWS, positionWS.x);
                output.bitangentWS = float4(normalInput.bitangentWS, positionWS.y);
                output.normalWS = float4(normalInput.normalWS, positionWS.z);

                return output;
            }


            half4 DepthNormalsFragment(Varyings input) : SV_TARGET
            {
                // get info
                float3 tangentWS = input.tangentWS.xyz;
                float3 bitangentWS = input.bitangentWS.xyz;
                float3 normalWS = input.normalWS.xyz;
                float3 positionWS = float3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
                float3x3 TBN = float3x3(tangentWS, bitangentWS, normalWS);

                float4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv);
                float3 N = mul(UnpackNormal(normalMap), TBN);
                return half4(N, 0);
            }


            ENDHLSL
        }

    }


    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100

        Pass
        {
            Name "CommonLOD100"

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            // 选项
            #pragma shader_feature_local_fragment _CLIP_ON
            #pragma shader_feature_local_fragment _ISOPAQUE_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 tangentOS : TANGENT;
                float3 normalOS : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 tangentWS : TEXCOORD1;
                float4 bitangentWS : TEXCOORD2;
                float4 normalWS : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


            Varyings Vertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(positionWS);
                
                output.uv = input.texcoord;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                half2 uv = input.uv;
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
				return baseMap;
            }
            
            ENDHLSL
        }

    }


    FallBack "Hidden/Universal Render Pipeline/FallbackError"

    CustomEditor "TATools.SimpleShaderGUI"
}
