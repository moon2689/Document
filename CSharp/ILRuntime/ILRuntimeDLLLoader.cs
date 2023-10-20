using System;
using System.Collections;
using System.IO;
using UnityEngine;
using UnityEngine.Networking;

public static class ILRuntimeDLLLoader
{
    #region EDLLLoadMode

    [Serializable]
    public enum EDLLLoadMode
    {
        LoadFromEditor,
        LoadFromStreaming,
        LoadFromRemote,
    }

    #endregion
    
    public const string
        FtpUrl = "ftp://172.18.3.158",
        VersionDay = "saber1";

    public static IEnumerator LoadDLLAsync(EDLLLoadMode dllLoadMode, Action<MemoryStream, MemoryStream> onLoaded)
    {
#if !UNITY_EDITOR
        if (dllLoadMode == EDLLLoadMode.LoadFromEditor)
            dllLoadMode = EDLLLoadMode.LoadFromStreaming;
#endif
        
        switch (dllLoadMode)
        {
            case EDLLLoadMode.LoadFromEditor:
                return LoadFromEditor(onLoaded);
            
            case EDLLLoadMode.LoadFromStreaming:
                return LoadFromStreaming(onLoaded);
            
            case EDLLLoadMode.LoadFromRemote:
                return LoadFromRemote(onLoaded);
                
            default:
                throw new InvalidOperationException();
        }
    }

    static IEnumerator LoadFromEditor(Action<MemoryStream, MemoryStream> onLoaded)
    {
        string pathDll = "ILRuntime/HotFix_Project.dll";
        byte[] dll = File.ReadAllBytes(pathDll);
        MemoryStream fs = new MemoryStream(dll);
        yield return null;

        //PDB文件是调试数据库，如需要在日志中显示报错的行号，则必须提供PDB文件，不过由于会额外耗用内存，正式发布时请将PDB去掉，下面LoadAssembly的时候pdb传null即可
        string pathPDB = "ILRuntime/HotFix_Project.pdb";
        byte[] pdb = File.ReadAllBytes(pathPDB);
        MemoryStream p = new MemoryStream(pdb);
        yield return null;

        onLoaded(fs, p);
    }

    static IEnumerator LoadFromStreaming(Action<MemoryStream, MemoryStream> onLoaded)
    {
        // 从streaming加载
        string abLocalPath = Application.streamingAssetsPath + "/idol.bundle";
        AssetBundle ab = AssetBundle.LoadFromFile(abLocalPath);
        Debug.Log("Load idol from local:" + abLocalPath);

        TextAsset taDll = ab.LoadAsset<TextAsset>("HotFix_Project.bytes");
        MemoryStream fs = new(taDll.bytes);
        yield return null;

        onLoaded(fs, null);
    }
    
    static IEnumerator LoadFromRemote(Action<MemoryStream, MemoryStream> onLoaded)
    {
        // download version
        bool isIOS = false;
#if UNITY_IPHONE
        isIOS = true;
#endif
        string platformFolder = isIOS ? "iOS" : "Android";
        string urlVersion = $"{FtpUrl}/{VersionDay}/{platformFolder}/ab/idolversion.txt";
        Debug.Log("Download idol version, url:" + urlVersion);
        UnityWebRequest www = UnityWebRequest.Get(urlVersion);
        www.timeout = 10;
        yield return www.SendWebRequest();
        uint version;
        if (www.result == UnityWebRequest.Result.Success)
        {
            string strVersion = www.downloadHandler.text;
            Debug.Log("Download idol version done, text:" + strVersion);
            uint.TryParse(strVersion, out version);
        }
        else
        {
            version = 0;
            Debug.LogError($"Download idol version failed, url:{urlVersion}, error:{www.error}");
        }
        www.Dispose();
        bool loadFromLocal = version == 0;

        AssetBundle ab;
        if (loadFromLocal)
        {
            // 从本地加载
            string abLocalPath = Application.streamingAssetsPath + "/idol.bundle";
            ab = AssetBundle.LoadFromFile(abLocalPath);
            Debug.Log("Load idol from local:" + abLocalPath);
        }
        else
        {
            // 从网络加载
            string urlIdol = $"{FtpUrl}/{VersionDay}/{platformFolder}/ab/idol.bundle";
            Debug.Log("Load idol from web:" + urlIdol);
            www = UnityWebRequestAssetBundle.GetAssetBundle(urlIdol, version, 0);
            www.timeout = 200;
            yield return www.SendWebRequest();

            if (www.result == UnityWebRequest.Result.Success)
            {
                ab = ((DownloadHandlerAssetBundle)www.downloadHandler).assetBundle;
                www.Dispose();
                Debug.Log("Load idol from web done");
            }
            else
            {
                www.Dispose();
                Debug.LogError("Load idol failed, error: " + www.error);
                yield break;
            }
        }

        TextAsset taDll = ab.LoadAsset<TextAsset>("HotFix_Project.bytes");
        MemoryStream fs = new(taDll.bytes);
        onLoaded(fs, null);
    }


}
