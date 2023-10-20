using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

//https://github.com/iryoku/separable-sss/blob/master/Demo/Code/SeparableSSS.cpp
public class SSSSRenderFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class  Setting
    {
        public bool DebugSkin =false;
        public bool DisableSkinShLighting =false;
        [Range(0,5)]
        public float SubsurfaceScaler = 0.25f;
        public Color SubsurfaceColor = new Color(0.48f, 0.41f, 0.28f,1f);
        public Color SubsurfaceFalloff= new Color(1.0f, 0.37f, 0.3f,1f) ;
        public float MaxDistance;
    }

    public Setting setting;

    class CustomRenderPass : ScriptableRenderPass
    {
        public Setting setting;
        
        private static List<Vector4> KernelArray = new List<Vector4>();
        
        static int ID_Kernel = Shader.PropertyToID("_Kernel");
        static int ID_SSSScaler = Shader.PropertyToID("_SSSScale");
        static int ID_ScreenSize = Shader.PropertyToID("_ScreenSize");
        
        static int ID_SSSBlurRT = Shader.PropertyToID("_SSSBlurRT");
        
        // static int ID_TanHalfFOV = Shader.PropertyToID("_TanHalfFOV");
        static int ID_FOV = Shader.PropertyToID("_FOV");
        static int ID_MaxDistance = Shader.PropertyToID("_MaxDistance");

        private Material ssssMat;
        // private int ID_SkinDepthRT  = Shader.PropertyToID("_CameraDepthTexture");
        private int ID_SkinDepthRT  = Shader.PropertyToID("_SkinDepthRT");
        
        private RenderTargetHandle Handle_SkinDiffuseRT;
        private RenderTargetHandle Handle_BlurRT;
        private RenderTargetHandle Handle_SkinDepthRT;
        
        ShaderTagId shaderTag= new ShaderTagId("SkinSSSS");
        
        static int ID_CameraDepthTexture= Shader.PropertyToID("_CameraDepthTexture");
        
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            Handle_SkinDiffuseRT.Init("Handle_SkinDiffuseRT");
            Handle_BlurRT.Init("Handle_BlurRT");
            Handle_SkinDepthRT.Init("Handle_SkinDepthRT");
            
            ssssMat = new Material(Shader.Find("Hidden/SeparableSubsurfaceScatter"));
            
            //计算出SSSBlur的kernel参数
            Vector3 SSSC = Vector3.Normalize(new Vector3 (setting.SubsurfaceColor.r, setting.SubsurfaceColor.g, setting.SubsurfaceColor.b));
            Vector3 SSSFC = Vector3.Normalize(new Vector3 (setting.SubsurfaceFalloff.r, setting.SubsurfaceFalloff.g, setting.SubsurfaceFalloff.b));
            // if(KernelArray.Count == 0) 
                SeparableSSSLibrary.CalculateKernel(KernelArray, 32, SSSC, SSSFC);

            var desc = renderingData.cameraData.cameraTargetDescriptor;
            desc.enableRandomWrite = true;
            cmd.GetTemporaryRT(Handle_SkinDiffuseRT.id,desc.width,desc.height,0);
            cmd.GetTemporaryRT(Handle_BlurRT.id,desc.width,desc.height,0);
            cmd.GetTemporaryRT(Handle_SkinDepthRT.id,desc.width,desc.height,24,FilterMode.Point,RenderTextureFormat.Depth);
            
            ssssMat.SetVector(ID_ScreenSize, new Vector4(desc.width, desc.height, 1f/desc.width, 1f/desc.height));
            ssssMat.SetVectorArray(ID_Kernel, KernelArray);
            ssssMat.SetFloat(ID_SSSScaler, setting.SubsurfaceScaler);
            ssssMat.SetFloat(ID_ScreenSize, setting.SubsurfaceScaler);
            
            // float _TanHalfFOV = Mathf.Tan( Mathf.Deg2Rad*( renderingData.cameraData.camera.fieldOfView*0.5f));
            ssssMat.SetFloat(ID_FOV,renderingData.cameraData.camera.fieldOfView);
            ssssMat.SetFloat(ID_MaxDistance,setting.MaxDistance);
            
            //将这个RT设置为Render Target
            // ConfigureTarget(new RenderTargetIdentifier[]{Handle_BlurRT.id,Handle_SkinDepthRT.id}, );
            ConfigureTarget(Handle_BlurRT.id,Handle_SkinDepthRT.id);
            // //将RT清空为黑
            ConfigureClear(ClearFlag.All, Color.black);
            
            // cmd.SetGlobalTexture(ID_SSSBlurRT,Handle_BlurRT.id);
            // cmd.SetGlobalTexture(ID_SkinDepthRT,Handle_SkinDepthRT.id);
            
            cmd.SetGlobalTexture(ID_SSSBlurRT,Handle_BlurRT.id);
            cmd.SetGlobalTexture(ID_SkinDepthRT,Handle_SkinDepthRT.id);
        }

        void SetKeyword( CommandBuffer cmd)
        {
            if (setting.DebugSkin)
            {
                cmd.EnableShaderKeyword("ENABLE_SKIN_SSSS_DEBUG_ON");
            }
            else
            {
                cmd.DisableShaderKeyword("ENABLE_SKIN_SSSS_DEBUG_ON");
            }
            
            if (setting.DisableSkinShLighting)
            {
                cmd.EnableShaderKeyword("DISABLE_SKIN_SH");
            }
            else
            {
                cmd.DisableShaderKeyword("DISABLE_SKIN_SH");
            }
        }
        
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            //获取CMD
            CommandBuffer cmd = CommandBufferPool.Get("SSSS CMD");

            var camRT = renderingData.cameraData.renderer.cameraColorTarget;
            /*
            // cmd.SetRenderTarget(Handle_BlurRT.id,Handle_SkinDepthRT.id);
            cmd.SetRenderTarget(Handle_BlurRT.id,Handle_BlurRT.id);
            cmd.ClearRenderTarget(RTClearFlags.All,Color.black,1,0);
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            */
            SetKeyword(cmd);
            
            // cmd.SetRenderTarget(SSSBaseRT);
            // context.ExecuteCommandBuffer(cmd);
            // cmd.Clear();
           
            var drawingSettings = CreateDrawingSettings(shaderTag, ref renderingData, SortingCriteria.CommonOpaque);
            var filteringSettings = new FilteringSettings(RenderQueueRange.opaque);
            context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);
            
            //sssBlur
            //XBlur
            cmd.Blit(Handle_BlurRT.id,Handle_SkinDiffuseRT.id,ssssMat,0);
            //YBlur
            cmd.Blit(Handle_SkinDiffuseRT.id, Handle_BlurRT.id, ssssMat, 1);
 
            //执行 cmd
            context.ExecuteCommandBuffer(cmd);
            // cmd.Blit(Handle_BlurRT.id,renderingData.cameraData.renderer.cameraColorTarget);
            /*
            cmd.SetRenderTarget(renderingData.cameraData.renderer.cameraColorTarget,renderingData.cameraData.renderer.cameraDepthTarget);
            cmd.ClearRenderTarget(RTClearFlags.All,Color.black,1,0);
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            */
            //释放cmd
            CommandBufferPool.Release(cmd);

            
            // Graphics.SetRenderTarget(renderingData.cameraData.renderer.cameraColorTarget,renderingData.cameraData.renderer.cameraDepthTarget);
            // renderingData.cameraData.renderer.ConfigureCameraTarget(renderingData.cameraData.renderer.cameraColorTarget,renderingData.cameraData.renderer.cameraDepthTarget);
            //
            // ConfigureTarget(renderingData.cameraData.renderer.cameraColorTarget, BuiltinRenderTextureType.Depth);
            // ConfigureClear(ClearFlag.All, Color.black);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(Handle_SkinDiffuseRT.id);
            cmd.ReleaseTemporaryRT(Handle_BlurRT.id);
            cmd.ReleaseTemporaryRT(Handle_SkinDepthRT.id);
        }
    }

    CustomRenderPass m_ScriptablePass;

    /// <inheritdoc/>
    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass();
        m_ScriptablePass.setting = setting;

        //在画实心物体之前做sssBlur
        m_ScriptablePass.renderPassEvent = RenderPassEvent.BeforeRenderingOpaques;
        // m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


