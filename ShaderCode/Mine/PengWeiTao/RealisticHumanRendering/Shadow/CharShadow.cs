/*
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CharShadow : ScriptableRendererFeature
{
    class CustomRenderPass : ScriptableRenderPass
    {
        private GameObject Character = null;
        private CharacterShadowUtility characterShadowUtility = new CharacterShadowUtility();

        private RenderTexture CharacterShadowMapRT;

        private static int ID_CharacterShadowMap = Shader.PropertyToID("_CharacterShadowMap");

        private ShaderTagId shaderTag = new ShaderTagId("ShaderCaster");
        
        private SkinnedMeshRenderer[] meshRenders;
        
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            Character = GameObject.FindWithTag("Character");
            
            Debug.Log("Character"+Character);
            
            int mainLightIndex = renderingData.lightData.mainLightIndex;
            if(mainLightIndex ==-1)
                return;

            if(Character == null)
                return;
            
            meshRenders = Character.GetComponentsInChildren<SkinnedMeshRenderer>();
            if (meshRenders == null)
                return;
            
            VisibleLight visibleLight = renderingData.lightData.visibleLights[mainLightIndex];
            Light mainLight = visibleLight.light;

            if (mainLight == null)
            {
                Debug.Log("no light");
                return;
            }
            

            // CharacterShadowMapRT = RenderTexture.GetTemporary(2048,2048,24,RenderTextureFormat.Depth);
            CharacterShadowMapRT = RenderTexture.GetTemporary(2048,2048,24,RenderTextureFormat.R16);
            
            cmd.SetGlobalTexture(ID_CharacterShadowMap,CharacterShadowMapRT);
            
            ConfigureTarget(CharacterShadowMapRT );
            ConfigureClear(ClearFlag.All, Color.black);
            
            characterShadowUtility.Init(Character.transform,mainLight,10f);
            
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            int mainLightIndex = renderingData.lightData.mainLightIndex;
            if(mainLightIndex ==-1)
                return;
            
            if(Character == null)
                return;
            
            if (meshRenders == null)
                return;

            var cmd = CommandBufferPool.Get("Character Shadow CMD");


            // for (int i = 0; i < meshRenders; i++)
            // {
            //     cmd.DrawRenderer();
            // }
            
            var viewAndProjection = characterShadowUtility.GetViewAndProjectionMatrix();
            cmd.SetViewProjectionMatrices(viewAndProjection.View,viewAndProjection.Projection);
            context.ExecuteCommandBuffer(cmd);
            
            var drawingSettings = CreateDrawingSettings(shaderTag, ref renderingData, SortingCriteria.CommonOpaque);
            var filteringSettings = new FilteringSettings(RenderQueueRange.opaque);
            context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);
            
            // context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            if (CharacterShadowMapRT)
            {
                CharacterShadowMapRT.Release();
            }
        }
    }

    CustomRenderPass m_ScriptablePass;

    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass();
        m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingShadows;
    }

    
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


*/