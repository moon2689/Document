﻿using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;

public class ProjectHelper : EditorWindow
{
	private Shader mFindShader;
	private Object m_source;

	public static void ShowWindow()
	{
		var window = GetWindow<ProjectHelper>();
		window.titleContent = new GUIContent("Shader引用查找");
		window.Show();
	}

    void OnEnable()
    {
        titleContent = new GUIContent("Shader引用查找");
    }

    void OnGUI() {
		EditorGUILayout.Separator();
		GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(1) });
		EditorGUILayout.Separator();

		EditorGUILayout.LabelField("检索出指定Shader的材质球");
		EditorGUILayout.BeginHorizontal();
		//mFindShader = EditorGUILayout.ObjectField("要查找的Shader", mFindShader,typeof(Shader)) as Shader;
		mFindShader = null;		// TODO
        if (GUILayout.Button("Find", GUILayout.Width(50)))
		{
			if(mFindShader != null)
			ListMaterialByShader(mFindShader, m_source);
		}
		EditorGUILayout.EndHorizontal();
		//m_source = EditorGUILayout.ObjectField("检索目录", m_source, typeof(Object), false, GUILayout.Width(300));
		//EditorGUILayout.Separator();
		//GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(1) });
		EditorGUILayout.Separator();
	}
	public void ListMaterialByShader(Shader shader,Object m_source)
	{

		//string[] paths = AssetDatabase.GetAllAssetPaths();
		//string rootPath = AssetDatabase.GetAssetPath(m_source);
		string rootPath = "Assets/";
		DirectoryInfo direction = new DirectoryInfo(rootPath);

		FileInfo[] files = direction.GetFiles("*.mat", SearchOption.AllDirectories);
		List<string> paths = new List<string>();
		for (int index = 0; index < files.Length; index++)
		{
			////过滤掉临时文件
			//if (!files[index].Name.EndsWith(".mat"))
			//{
			//    continue;
			//}
			paths.Add(files[index].ToString());
		}
		int sum = paths.Count;
		int i = 0;
		float progress = 0.0f;

		foreach (var path in paths)
		{
			i++;
			progress = (float)i / (float)sum;
			string info = string.Format("正在处理:{0}/{1}", i, sum);
			var objPath = "Assets" + path.Replace("\\", "/").Replace(Application.dataPath, "");
			if (EditorUtility.DisplayCancelableProgressBar(objPath, info, progress))
			{
				EditorUtility.ClearProgressBar();
				return;
			}
			var mat = AssetDatabase.LoadAssetAtPath<Material>(objPath);
			if (mat != null)
			{
				if (mat.shader != null)
				{
					if (mat.shader.name.Equals(shader.name))
					{
						UnityEngine.Debug.LogError("检索:" + mat.name, mat);
					}
				}
			}
		}
		EditorUtility.ClearProgressBar();
	}
}
