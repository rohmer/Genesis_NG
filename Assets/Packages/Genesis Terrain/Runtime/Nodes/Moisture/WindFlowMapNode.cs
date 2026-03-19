using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;


using System;

using UnityEngine;
using UnityEngine.Rendering;


namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{
    [Documentation(@"
Creates a wind flow map from a Terrain heightmap.
")]
    [Serializable, NodeMenuItem("Terrain/Moisture/Wind Flow Map")]
    public class WindFlowMapNode : GenesisNode
    {
        [SerializeField, Input(name = "Height Map", allowMultiple = false)]
        public HeightField TerrainInput;

        [SerializeField, Output(name = "Wind Flow")]
        public WindFlowOutput Output;
        
        public override string name => "Wind Flow Map";
        public override bool showDefaultInspector => false;
        public override bool hasPreview => true;
        public override bool hasSettings => false;
        public override float nodeWidth => 300;
        internal Texture2D preview;
        public override Texture previewTexture => preview;

        ComputeShader shader;

        [Header("Wind Settings")]
        public Vector2 baseWind = new Vector2(1, 0);
        [Range(0, 2)] public float terrainInfluence = 1f;
        [Range(0, 1)] public float occlusionStrength = 0.5f;

        [Header("Advection")]
        [Range(0, 1)] public float advectionStrength = 0.75f;
        public int advectionSteps = 4;
        public float stepSize = 1f;

        [Header("Multi-Scale Weights")]
        [Range(0, 1)] public float wMacro = 0.6f;
        [Range(0, 1)] public float wMeso = 0.3f;
        [Range(0, 1)] public float wMicro = 0.1f;

        [Header("Sampling Radii")]
        public int rMacro = 16;
        public int rMeso = 6;
        public int rMicro = 2;

        public enum eDebugViz
        {
            Gradient = 1,
            Curvature = 2,
            Occulsion = 3,
            FlowDirection =4,
            FlowMagnitude = 5,
            FlowHSV = 6
        }
        [Header("Debug Visualization")]
        public eDebugViz debugMode = eDebugViz.FlowDirection; // 0=off, 1=grad, 2=curv, 3=occ, 4=flowDir, 5=flowMag, 6=flowHSV
        public RenderTexture debugOutput;

        // Internal buffers
        RenderTexture gradMacro, gradMeso, gradMicro;
        RenderTexture curvMacro, curvMeso, curvMicro;
        RenderTexture gradBlend, curvBlend;
        RenderTexture flowInitial, occlusionMask;
        RenderTexture flowPrev, flowOut;
        RenderTexture windFlowMap;

        int size;


        protected override void Enable()
        {
            base.Enable();
            preview = new Texture2D(300, 300);
        }

        static Texture2D ToPreviewTexture(RenderTexture rt, int previewres = 256)
        {
            int w = rt.width;
            int h = rt.height;

            float scale = Mathf.Min((float)previewres / w, (float)previewres / h);
            int pw = Mathf.RoundToInt(w * scale);
            int ph = Mathf.RoundToInt(h * scale);

            RenderTexture tmp = RenderTexture.GetTemporary(pw, ph, 0, rt.format);
            Graphics.Blit(rt, tmp);

            Texture2D tex = new Texture2D(pw, ph, TextureFormat.RGBAFloat, false, true);

            RenderTexture prev = RenderTexture.active;
            RenderTexture.active = tmp;

            tex.ReadPixels(new Rect(0, 0, pw, ph), 0, 0);
            tex.Apply(false, false);

            RenderTexture.active = prev;
            RenderTexture.ReleaseTemporary(tmp);

            return tex;
        }

        RenderTexture CreateRT(int w, int h, RenderTextureFormat fmt)
        {
            var rt = new RenderTexture(w, h, 0, fmt);
            rt.enableRandomWrite = true;
            rt.filterMode = FilterMode.Point;
            rt.wrapMode = TextureWrapMode.Clamp;
            rt.Create();
            return rt;
        }


        protected override bool ProcessNode(CommandBuffer cmd)
        {
            bool r = base.ProcessNode(cmd);
            if (TerrainInput == null)
                return r;
            if (shader == null)
                shader = Resources.Load<ComputeShader>("Shaders/AdvMoisture/Flowmap");
            GenerateWindFlow();
            return r;
        }

        public void GenerateWindFlow()
        {
            size = TerrainInput.mapSize;
            
            windFlowMap = CreateRT(size, size, RenderTextureFormat.RGFloat);
            debugOutput = CreateRT(size, size, RenderTextureFormat.ARGBFloat);

            gradMacro = CreateRT(size, size, RenderTextureFormat.RGFloat);
            gradMeso = CreateRT(size, size, RenderTextureFormat.RGFloat);
            gradMicro = CreateRT(size, size, RenderTextureFormat.RGFloat);

            curvMacro = CreateRT(size, size, RenderTextureFormat.RFloat);
            curvMeso = CreateRT(size, size, RenderTextureFormat.RFloat);
            curvMicro = CreateRT(size, size, RenderTextureFormat.RFloat);

            gradBlend = CreateRT(size, size, RenderTextureFormat.RGFloat);
            curvBlend = CreateRT(size, size, RenderTextureFormat.RFloat);

            flowInitial = CreateRT(size, size, RenderTextureFormat.RGFloat);
            occlusionMask = CreateRT(size, size, RenderTextureFormat.RFloat);

            flowPrev = CreateRT(size, size, RenderTextureFormat.RGFloat);
            flowOut = CreateRT(size, size, RenderTextureFormat.RGFloat);

            shader.SetInt("Width", size);
            shader.SetInt("Height", size);

            shader.SetVector("BaseWind", baseWind.normalized);
            shader.SetFloat("TerrainInfluence", terrainInfluence);
            shader.SetFloat("OcclusionStrength", occlusionStrength);

            shader.SetFloat("AdvectionStrength", advectionStrength);
            shader.SetFloat("StepSize", stepSize);

            shader.SetFloat("WMacro", wMacro);
            shader.SetFloat("WMeso", wMeso);
            shader.SetFloat("WMicro", wMicro);

            shader.SetInt("RMacro", rMacro);
            shader.SetInt("RMeso", rMeso);
            shader.SetInt("RMicro", rMicro);

            shader.SetInt("DebugMode", (int)debugMode);

            shader.SetTexture(0, "Heightmap", TerrainInput.HeightMap);

            int kGradMacro = shader.FindKernel("CS_GradMacro");
            int kGradMeso = shader.FindKernel("CS_GradMeso");
            int kGradMicro = shader.FindKernel("CS_GradMicro");
            int kBlend = shader.FindKernel("CS_BlendScales");
            int kWind = shader.FindKernel("CS_WindDeflect");
            int kOcc = shader.FindKernel("CS_Occlusion");
            int kAdv = shader.FindKernel("CS_Advect");
            int kNorm = shader.FindKernel("CS_Normalize");
            int kDebug = shader.FindKernel("CS_DebugVisualize");

            // Bind textures
            shader.SetTexture(kGradMacro, "GradMacro", gradMacro);
            shader.SetTexture(kGradMeso, "GradMeso", gradMeso);
            shader.SetTexture(kGradMeso, "CurvMeso", curvMeso);
            shader.SetTexture(kGradMacro, "Heightmap", TerrainInput.HeightMap);
            shader.SetTexture(kGradMacro, "CurvMacro", curvMacro);

            shader.SetTexture(kGradMeso, "GradMacro", gradMacro);
            
            shader.SetTexture(kGradMeso, "Heightmap", TerrainInput.HeightMap);
            shader.SetTexture(kGradMeso, "CurvMacro", curvMacro);

            shader.SetTexture(kGradMicro, "GradMicro", gradMicro);
            shader.SetTexture(kGradMicro, "GradMacro", gradMacro);
            shader.SetTexture(kGradMicro, "Heightmap", TerrainInput.HeightMap);
            shader.SetTexture(kGradMicro, "CurvMacro", curvMacro);
            shader.SetTexture(kGradMicro, "CurvMicro", curvMicro);

            shader.SetTexture(kBlend, "GradMacro", gradMacro);
            shader.SetTexture(kBlend, "GradMeso", gradMeso);
            shader.SetTexture(kBlend, "GradMicro", gradMicro);
            shader.SetTexture(kBlend, "CurvMacro", curvMacro);
            shader.SetTexture(kBlend, "CurvMeso", curvMeso);
            shader.SetTexture(kBlend, "CurvMicro", curvMicro);
            shader.SetTexture(kBlend, "GradBlended", gradBlend);
            shader.SetTexture(kBlend, "CurvBlended", curvBlend);

            shader.SetTexture(kWind, "GradBlended", gradBlend);
            shader.SetTexture(kWind, "FlowInitial", flowInitial);

            shader.SetTexture(kOcc, "CurvBlended", curvBlend);
            shader.SetTexture(kOcc, "OcclusionMask", occlusionMask);

            shader.SetTexture(kAdv, "FlowInitial", flowInitial);
            shader.SetTexture(kAdv, "FlowPrev", flowPrev);
            shader.SetTexture(kAdv, "FlowOut", flowOut);

            shader.SetTexture(kNorm, "FlowOut", flowOut);

            shader.SetTexture(kDebug, "GradBlended", gradBlend);
            shader.SetTexture(kDebug, "CurvBlended", curvBlend);
            shader.SetTexture(kDebug, "OcclusionMask", occlusionMask);
            shader.SetTexture(kDebug, "FlowOut", flowOut);
            shader.SetTexture(kDebug, "DebugOut", debugOutput);
            int gx = Mathf.CeilToInt(size / 8f);
            int gy = Mathf.CeilToInt(size / 8f);

            // Run pipeline
            shader.Dispatch(kGradMacro, gx, gy, 1);
            shader.Dispatch(kGradMeso, gx, gy, 1);
            shader.Dispatch(kGradMicro, gx, gy, 1);

            shader.Dispatch(kBlend, gx, gy, 1);
            shader.Dispatch(kWind, gx, gy, 1);
            shader.Dispatch(kOcc, gx, gy, 1);

            // Advection ping-pong
            Graphics.CopyTexture(flowInitial, flowPrev);
            for (int i = 0; i < advectionSteps; i++)
            {
                shader.Dispatch(kAdv, gx, gy, 1);
                Graphics.CopyTexture(flowOut, flowPrev);
            }

            shader.Dispatch(kNorm, gx, gy, 1);
            // Final flow map
            Graphics.CopyTexture(flowOut, windFlowMap);
            shader.Dispatch(kDebug, gx, gy, 1);
            preview = ToPreviewTexture(debugOutput, 300);

            Output = new WindFlowOutput();
            Output.FlowMap = CreateRT(size, size, RenderTextureFormat.RGFloat);
            Graphics.CopyTexture(windFlowMap, Output.FlowMap);
            Output.Curvature= CreateRT(size, size, RenderTextureFormat.RFloat);
            Graphics.CopyTexture(curvBlend, Output.Curvature);
            Output.HeightMap = CreateRT(size, size, TerrainInput.HeightMap.format);
            Graphics.CopyTexture(TerrainInput.HeightMap, Output.HeightMap);
            Output.Occulsion= CreateRT(size, size, RenderTextureFormat.RFloat);
            Graphics.CopyTexture(occlusionMask, Output.Occulsion);

        }   

    }
}
