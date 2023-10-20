using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using CSObjectWrapEditor;
using UnityEditor;
using UnityEngine;
using YooAsset.Editor;

public class JenkinsTool : ScriptableObject
{
    static string[] BuildingScenes
    {
        get
        {
            List<string> scenes = new List<string>();
            foreach (EditorBuildSettingsScene scene in EditorBuildSettings.scenes)
            {
                if (scene != null && scene.enabled)
                    scenes.Add(scene.path);
            }
            return scenes.ToArray();
        }
    }


    public static string GetArg(string name, string defaultArg)
    {
        if (string.IsNullOrEmpty(name))
            return defaultArg;

        string[] args = Environment.GetCommandLineArgs();
        string argStart = string.Format("{0}=", name);

        foreach (string arg in args)
        {
            if (arg.StartsWith(argStart))
            {
                string argFixed = arg.Substring(argStart.Length);
                return string.IsNullOrEmpty(argFixed) ? defaultArg : argFixed;
            }
        }

        return defaultArg;
    }

    public static void BuildAB()
    {
        bool convertConfig = GetArg("m_ConvertConfig", "false") == "true";
        bool buildAB = GetArg("m_BuildAB", "false") == "true";
        string strBuildTarget = GetArg("m_BuildTarget", "Android");
        BuildTarget buildTarget = (BuildTarget)Enum.Parse(typeof(BuildTarget), strBuildTarget);

        if (convertConfig)
            ConvertConfig();
        if (buildAB)
            YooAssetBuild(buildTarget);

        Debug.Log("#Jenkins, JenkinsTool.BuildAB() finished! ");
    }

    [MenuItem("FashionBeat/Jenkins/ConvertConfig")]
    static void ConvertConfig()
    {
        ConfigConverter.JenkinsConvertConfig();
        Debug.Log("#Jenkins, ConfigConverter.ConvertAllConfig() finished! ");
    }

    static void YooAssetBuild(BuildTarget buildTarget)
    {
        Debug.Log($"#Jenkins, Yoo asset 开始构建 : {buildTarget}");

        bool forceRebuild = GetArg("m_ForceRebuild", "false") == "true";
        var buildMode = forceRebuild ? EBuildMode.ForceRebuild : EBuildMode.IncrementalBuild;

        bool copyAB = GetArg("m_CopyABToStream", "false") == "true";
        ECopyBuildinFileOption copyOption = copyAB ? ECopyBuildinFileOption.ClearAndCopyByTags : ECopyBuildinFileOption.None;
        string copyTags = copyAB ? "local;" : "";

        Debug.Log("m_ForceRebuild=" + forceRebuild);
        Debug.Log("m_CopyABToStream=" + copyAB);

        // 构建参数
        BuildParameters p = new BuildParameters()
        {
            OutputRoot = AssetBundleBuilderHelper.GetDefaultOutputRoot(),
            BuildTarget = buildTarget,
            BuildPipeline = EBuildPipeline.BuiltinBuildPipeline,
            BuildMode = buildMode,
            BuildPackage = "DefaultPackage",
            HumanReadableVersion = "a",
            VerifyBuildingResult = true,
            EnableAddressable = true,
            EncryptionServices = null,
            OutputNameStyle = EOutputNameStyle.HashName,
            CopyBuildinFileOption = copyOption,
            CopyBuildinFileTags = copyTags,
            CompressOption = ECompressOption.LZ4,
        };

        // 执行构建
        AssetBundleBuilder builder = new AssetBundleBuilder();
        var buildResult = builder.Run(p);

        if (copyAB)
        {
            YooAssetTool.CopyBundleToStream();
        }

        Debug.Log($"#Jenkins, ConfigConverter.YooBuildInternal() finished,result {buildResult.Success}");
    }

    [MenuItem("FashionBeat/Jenkins/BuildPlayer")]
    public static void BuildPlayer()
    {
        bool generateLua = GetArg("m_GenerateLua", "false") == "true";
        if (generateLua)
        {
            Generator.ClearAll();
            Generator.GenAll();
        }

        string path = GetArg("m_ExportPath", "");
        if (string.IsNullOrEmpty(path))
        {
            path = "../../export";
        }

        if (Directory.Exists(path))
        {
            Directory.Delete(path, true);
        }

        BuildTarget target = BuildTarget.Android;
        BuildOptions options = BuildOptions.None;
        EditorUserBuildSettings.exportAsGoogleAndroidProject = true;
        EditorUserBuildSettings.androidBuildSystem = AndroidBuildSystem.Gradle;
        BuildPipeline.BuildPlayer(BuildingScenes, path, target, options);
    }

    [MenuItem("FashionBeat/Jenkins/BuildAPK")]
    public static void BuildAPK()
    {
        bool generateLua = GetArg("m_GenerateLua", "false") == "true";
        if (generateLua)
        {
            Generator.ClearAll();
            Generator.GenAll();
        }

        string path = GetArg("m_ExportPath", "");
        if (string.IsNullOrEmpty(path))
        {
            path = "../../1.apk";
        }

        Debug.Log("m_ExportPath=" + path);

        if (File.Exists(path))
            File.Delete(path);

        string dirPath = Path.GetDirectoryName(path);
        if (!Directory.Exists(dirPath))
            Directory.CreateDirectory(dirPath);

        BuildTarget target = BuildTarget.Android;
        BuildOptions options = BuildOptions.None;
        EditorUserBuildSettings.exportAsGoogleAndroidProject = false;
        //EditorUserBuildSettings.androidBuildSystem = AndroidBuildSystem.Gradle;
        BuildPipeline.BuildPlayer(BuildingScenes, path, target, options);
    }

    [MenuItem("FashionBeat/Jenkins/ExportLoc")]
    public static void ExportLoc()
    {
        bool getChinese = GetArg("m_GetChinese", "true") == "true";
        string folder = GetArg("m_ExportPath", "C:\\");
        Language lan = (Language)Enum.Parse(typeof(Language), GetArg("m_Language", "English"));
        if (getChinese)
        {
            LocalizationTools.Jenkins_GetChinese();
        }
        LocalizationTools.Jenkins_ExportUnloc(lan, folder);
        LocalizationTools.Jenkins_ExportAllLocText(folder);
    }

    public static void ImportLoc()
    {
        string path = GetArg("m_LocalizedExcel", "");
        Language lan = (Language)Enum.Parse(typeof(Language), GetArg("m_Language", "English"));
        if (!string.IsNullOrEmpty(path))
        {
            LocalizationTools.Localize(lan, path);
        }
    }

}
