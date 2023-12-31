/*
Shader Control - (C) Copyright 2016-2022 Ramiro Oliva (Kronnect)
*/

using UnityEngine;
using UnityEditor;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using UnityEditorInternal;

namespace ShaderControl {

    public class SCWindowAdvanced : EditorWindow {

        ShadersBuildInfo shadersBuildInfo;
        Vector2 scrollViewPosProject;
        GUIStyle titleStyle;
        public ShaderBuildInfo shader;
        public SCShader projectShader;
        StringBuilder sb = new StringBuilder();

        public static void ShowWindow(ShaderBuildInfo shader, SCShader projectShader) {
            SCWindowAdvanced window = GetWindow<SCWindowAdvanced>(true, "Advanced Build Options", true);
            window.shader = shader;
            window.projectShader = projectShader;
        }


        void OnGUI() {
            if (titleStyle == null) {
                titleStyle = new GUIStyle(GUI.skin.box);
                titleStyle.normal.textColor = EditorGUIUtility.isProSkin ? Color.white : Color.black;
                titleStyle.richText = true;
                titleStyle.alignment = TextAnchor.MiddleLeft;
            }
            if (shadersBuildInfo == null) {
                shadersBuildInfo = ShaderDebugBuildProcessor.CheckShadersBuildStore(shadersBuildInfo);
            }

            DrawAdvancedGUI();

        }

        void DrawAdvancedGUI() {

            GUILayout.Box(new GUIContent("This window let you specify which shader variants are allowed during build."), titleStyle, GUILayout.ExpandWidth(true));
            EditorGUILayout.Separator();

            if (shader == null) {
                Close();
                return;
            }

            EditorGUIUtility.labelWidth = 100;
            EditorGUILayout.Separator();
            EditorGUILayout.LabelField("Shader:", shader.name);
            EditorGUILayout.Separator();

            int kwCount = shader.keywords == null ? 0 : shader.keywords.Count;
            if (kwCount == 0) {
                EditorGUILayout.LabelField("No keywords.");
                return;
            }

            GUILayout.Label("Select keyword set (keywords in same group are mutually exclusive):");

            EditorGUI.indentLevel++;
            int prevGroup = 0;
            GUILayout.BeginVertical(GUI.skin.box);
            EditorGUILayout.BeginHorizontal();
            float width = EditorGUIUtility.currentViewWidth / 4;
            if (projectShader == null) {
                for (int j = 0, visibleCount = 0; j < kwCount; j++) {
                    KeywordBuildSettings kw = shader.keywords[j];
                    if (kw == null) continue;
                    if (visibleCount++ > 3) {
                        visibleCount = 0;
                        EditorGUILayout.EndHorizontal();
                        EditorGUILayout.BeginHorizontal();
                    }
                    kw.includeInVariant = EditorGUILayout.ToggleLeft(kw.keyword, kw.includeInVariant, GUILayout.MinWidth(width));
                }
            } else {
                for (int j = 0, visibleCount = 0; j < kwCount; j++) {
                    KeywordBuildSettings kw = shader.keywords[j];
                    if (kw == null) continue;
                    SCKeyword keyword = projectShader.GetKeyword(kw.keyword);
                    if (keyword != null) {
                        if (prevGroup == 0) {
                            prevGroup = keyword.lineNumber;
                        }
                        if (keyword.lineNumber != prevGroup) {
                            prevGroup = keyword.lineNumber;
                            EditorGUILayout.EndHorizontal();
                            GUILayout.EndVertical();
                            GUILayout.BeginVertical(GUI.skin.box);
                            EditorGUILayout.BeginHorizontal();
                            visibleCount = 0;
                        } else if (visibleCount++ > 3) {
                            visibleCount = 0;
                            EditorGUILayout.EndHorizontal();
                            EditorGUILayout.BeginHorizontal();
                        }
                    }
                    EditorGUI.BeginChangeCheck();
                    kw.includeInVariant = EditorGUILayout.ToggleLeft(kw.keyword, kw.includeInVariant, GUILayout.MinWidth(width));
                    if (EditorGUI.EndChangeCheck() && kw.includeInVariant) {
                        if (keyword.lineNumber > 0) {
                            for (int i = 0; i < kwCount; i++) {
                                if (i == j) continue;
                                SCKeyword otherKeyword = projectShader.GetKeyword(shader.keywords[i].keyword);
                                if (otherKeyword != null && otherKeyword.lineNumber == keyword.lineNumber) {
                                    shader.keywords[i].includeInVariant = false;
                                }
                            }
                        }
                    }
                }
            }
            EditorGUILayout.EndHorizontal();
            GUILayout.EndVertical();
            EditorGUI.indentLevel--;

            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("Add Variant", GUILayout.Width(140))) {
                AddVariant(shader);
                GUIUtility.ExitGUI();
            }
            if (GUILayout.Button("Add Permutations", GUILayout.Width(140))) {
                AddPermutations(shader);
                GUIUtility.ExitGUI();
            }
            EditorGUILayout.EndHorizontal();
            GUI.enabled = shader.variants.Count > 0;
            if (GUILayout.Button("Create Shader Variant Collection Asset", GUILayout.Width(280))) {
                CreateShaderVariantCollection(shader);
                GUIUtility.ExitGUI();
            }
            GUI.enabled = true;

            EditorGUILayout.Separator();

            // Show current variants
            if (shader.variants != null) {
                int keywordSetsCount = shader.variants.Count;
                if (keywordSetsCount > 0) {
                    GUILayout.Label("Current allowed keywords combinations:");
                }

                scrollViewPosProject = EditorGUILayout.BeginScrollView(scrollViewPosProject);

                for (int k = 0; k < keywordSetsCount; k++) {
                    EditorGUILayout.Separator();
                    KeywordSet keywordSet = shader.variants[k];
                    sb.Length = 0;
                    sb.Append("Variant ");
                    sb.Append(k + 1);
                    sb.Append(": ");
                    foreach (string keyword in keywordSet.keywords) {
                        sb.Append(keyword);
                        sb.Append(" ");
                    }
                    GUILayout.Label(sb.ToString());
                    EditorGUILayout.BeginHorizontal();
                    GUILayout.Space(20);
                    if (GUILayout.Button("Remove", GUILayout.Width(100))) {
                        shader.variants.RemoveAt(k);
                        RefreshShadersBuildInfo();
                        GUIUtility.ExitGUI();
                    }
                    EditorGUILayout.EndHorizontal();
                }
                EditorGUILayout.EndScrollView();
            }
        }

        void AddVariant(ShaderBuildInfo shader) {
            int kwCount = shader.keywords.Count;
            int includedCount = 0;
            KeywordSet ks = new KeywordSet();
            for (int j = 0; j < kwCount; j++) {
                if (shader.keywords[j].includeInVariant) {
                    includedCount++;
                    ks.keywords.Add(shader.keywords[j].keyword);
                }
            }
            if (includedCount > 0) {
                AddKeywordSet(shader, ks);
            }
        }

        void AddPermutations(ShaderBuildInfo shader) {
            int kwCount = shader.keywords.Count;
            List<string> all = new List<string>();
            for (int j = 0; j < kwCount; j++) {
                if (shader.keywords[j].includeInVariant) all.Add(shader.keywords[j].keyword);
            }
            foreach (var variant in StringPerm.GetCombinations(all)) {
                KeywordSet ks = new KeywordSet();
                foreach (string keyword in variant) {
                    ks.keywords.Add(keyword);
                }
                AddKeywordSet(shader, ks);
            }
        }

        void AddKeywordSet(ShaderBuildInfo shader, KeywordSet ks) {
            // check uniqueness
            bool repeated = false;
            foreach (var existingVariant in shader.variants) {
                if (ks.keywords.All(existingVariant.keywords.Contains) && ks.keywords.Count == existingVariant.keywords.Count) {
                    repeated = true;
                    break;
                }
            }
            if (!repeated) {
                shader.variants.Add(ks);
                RefreshShadersBuildInfo();
            }
        }


        void CreateShaderVariantCollection(ShaderBuildInfo shader) {
            Shader unityShader = Shader.Find(shader.name);
            if (unityShader == null) {
                UnityEngine.Debug.LogError("Shader not found! " + shader.name);
                return;
            }
            ShaderVariantCollection svc = new ShaderVariantCollection();
            foreach (var variant in shader.variants) {
                ShaderVariantCollection.ShaderVariant sv = new ShaderVariantCollection.ShaderVariant();
                sv.shader = unityShader;
                sv.passType = UnityEngine.Rendering.PassType.Normal;
                sv.keywords = variant.keywords.ToArray();
                svc.Add(sv);
            }
            AssetDatabase.CreateAsset(svc, "Assets/ShaderVariantCollection.asset");
            AssetDatabase.Refresh();
            Selection.activeObject = svc;
            EditorGUIUtility.PingObject(svc);
        }

        void RefreshShadersBuildInfo() {
            EditorUtility.SetDirty(shadersBuildInfo);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            InternalEditorUtility.RepaintAllViews();
        }



    }

}