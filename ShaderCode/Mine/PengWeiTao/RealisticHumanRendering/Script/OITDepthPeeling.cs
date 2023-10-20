using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System.Collections.Generic;

public class OITDepthPeeling : ScriptableRendererFeature
{
    [System.Serializable]
    public class Setting
    {
        [Range(1, 16)] public int DepthPeelingPass = 6;
    }

    public Setting setting;
    
    class CustomRenderPass : ScriptableRenderPass
    {
        public Setting setting;

        private static int ID_DepthPeelingPassCount = Shader.PropertyToID("_DepthPeelingPassCount");

        private Material _depthPeelingBlendMaterial;

        private Material DepthPeelingBlendMaterial
        {
            get
            {
                if (_depthPeelingBlendMaterial == null)
                {
                   _depthPeelingBlendMaterial = new Material(Shader.Find("Hidden/DepthPeelingBlend"));
                }
                return _depthPeelingBlendMaterial;
            }
        }

        private ShaderTagId shaderTag;

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            shaderTag = new ShaderTagId("DepthPeelingPass");
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            int DepthPeelingPass = setting.DepthPeelingPass;
            int pixelWidth = renderingData.cameraData.camera.pixelWidth;
            int pixelHeight = renderingData.cameraData.camera.pixelHeight;

            var drawingSettings = CreateDrawingSettings(shaderTag, ref renderingData, SortingCriteria.CommonOpaque);
            var filteringSettings = new FilteringSettings(RenderQueueRange.transparent);
            var cmd = CommandBufferPool.Get("Depth Peeling");
            //将cmd分组
            using (new ProfilingSample(cmd, "Depth Peeling"))
            {
                // Start profilling
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                List<int> colorRTs = new List<int>(DepthPeelingPass);
                List<int> depthRTs = new List<int>(DepthPeelingPass);

                //从前往后画 半透明颜色RT 
                for (var i = 0; i < DepthPeelingPass; i++)
                {
                    depthRTs.Add(Shader.PropertyToID($"_DepthPeelingDepth{i}"));//_DepthPeelingDepth0 _DepthPeelingDepth1
                    colorRTs.Add(Shader.PropertyToID($"_DepthPeelingColor{i}"));//_DepthPeelingColor0 _DepthPeelingColor1
                    cmd.GetTemporaryRT(colorRTs[i], pixelWidth, pixelHeight, 0);
                    cmd.GetTemporaryRT(depthRTs[i], pixelWidth, pixelHeight, 32, FilterMode.Point, RenderTextureFormat.RFloat);
                    
                    //设置Pass次数
                    cmd.SetGlobalInt(ID_DepthPeelingPassCount,i);
                    //如果不是第一层，那么将上一层的深度RT传入shader
                    if (i > 0)
                    {
                        cmd.SetGlobalTexture("_MaxDepthTex", depthRTs[i - 1]);
                    }
                    
                    //设置MRT(multi render target) 颜色RT 深度RT
                    //将深度渲染在不同的RT上
                    cmd.SetRenderTarget(new RenderTargetIdentifier[] {colorRTs[i], depthRTs[i]}, depthRTs[i]);
                    cmd.ClearRenderTarget(true, true, Color.black);
                    context.ExecuteCommandBuffer(cmd);
                    cmd.Clear();
                    //画半透明颜色
                    context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);
                }
                
                //从后往前进行 半透明颜色RT的混合
                for (var i = DepthPeelingPass - 1; i >= 0; i--)
                {
                    // cmd.SetGlobalTexture("_DepthTex", depthRTs[i]);
                    cmd.SetGlobalTexture("_DepthTex", depthRTs[i]);

                    int pass = 0;
                    //第一次Blend时,与黑色Blend
                    if (i == DepthPeelingPass - 1)
                        pass = 1;
                    cmd.Blit(colorRTs[i], renderingData.cameraData.renderer.cameraColorTarget, DepthPeelingBlendMaterial, pass);

                    cmd.ReleaseTemporaryRT(depthRTs[i]);
                    cmd.ReleaseTemporaryRT(colorRTs[i]);
                }

                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
            cmd.Clear();
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }

    CustomRenderPass m_ScriptablePass;

    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass();
        m_ScriptablePass.setting = this.setting;
        m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}