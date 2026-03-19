using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using SharpVoronoiLib;

using System;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{
    [Documentation(@"
Moves moisture from a base moisture map using a flow map.
")]

    [Serializable, NodeMenuItem("Terrain/Moisture/Moisture Advection")]
    public class MoistureAdvectionNode : GenesisNode
    {
        [SerializeField, Input(name = "Moisture Map", allowMultiple = false)]
        public RenderTexture MoistureInput;

        [SerializeField, Input(name = "Wind Flow")]
        public WindFlowOutput WindFlowMap;

        [SerializeField, Output(name = "Moisture Output")]
        public RenderTexture MoistureOutput;

        [SerializeField, Output(name = "Wetness Map")]
        public RenderTexture Wetness;

        public RenderTexture RainMap;

        RenderTexture wetnessPrev;
        RenderTexture wetnessOut;

        public override string name => "Moisture Advection";
        public override bool showDefaultInspector => false;
        public override bool hasPreview => true;
        public override bool hasSettings => false;
        public override float nodeWidth => 300;
        internal Texture2D preview;
        public override Texture previewTexture => preview;
                
        [Header("Simulation Settings")]
        public int iterations = 6;
        public float stepSize = 1.0f;
        [Range(0, 1)] public float advectionStrength = 1.0f;

        [Header("Terrain Effects")]
        [Range(0, 1)] public float valleyPull = 0.5f;
        [Range(0, 1)] public float rainShadowStrength = 0.5f;
        [Range(0, 1)] public float evaporation = 0.0f;
        [Range(0, 1)] public float heightInfluence = 0.5f;

        [Header("Condensation")]
        public float condensationThreshold = 0.85f;
        public float precipitationRate = 1.0f;
        public float valleyRainBoost = 0.25f;
        public float rainShadowSuppression = 0.5f;

        [Header("Saturation Limits")]
        public float moistureMin = 0.0f;
        public float moistureMax = 1.0f;

        public int wetIter = 1;             // wetness evolves slowly
        [Range(0, 1)] public float precipToWetness = 0.5f;
        [Range(0, 1)] public float moistureToWetness = 0.2f;
        [Range(0, 1)] public float drainageStrength = 0.5f;
        [Range(0, 1)] public float valleyRetention = 0.3f;
        [Range(0, 1)] public float evaporationRate = 0.1f;
        [Header("Saturation Limits")]
        public float wetnessMin = 0.0f;
        public float wetnessMax = 1.0f;

        [Header("Recombination")]
        public float recombFactor = 1.0f;

        public enum eDebugViz { moisture=1, flow=2, combined=3, precipitation = 4, }
        [Header("Debug Visualization")]
        [Range(0, 3)] public eDebugViz debugMode = eDebugViz.combined; // 0=off, 1=moisture, 2=flow, 3=combined, 4=rain
        public RenderTexture debugOutput;

        // Internal buffers
        RenderTexture moisturePrev;
        RenderTexture moistureOut;
        
        int size;

        ComputeShader shader;

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
            if (MoistureInput == null || WindFlowMap==null)
                return r;
            
            ProcessFlowMap();
            return r;
        }

        void ClearRT(RenderTexture rt, float value)
        {
            RenderTexture active = RenderTexture.active;
            RenderTexture.active = rt;
            GL.Clear(false, true, new Color(value, value, value, value));
            RenderTexture.active = active;
        }

        public void ProcessFlowMap()
        {
            
            //if (shader == null)
                shader = Resources.Load<ComputeShader>("Shaders/AdvMoisture/MoistureAdvection");
            size = MoistureInput.width;
            debugOutput = CreateRT(size, size, RenderTextureFormat.ARGBFloat);

            moisturePrev = CreateRT(size, size, RenderTextureFormat.RFloat);
            MoistureOutput = CreateRT(size, size, RenderTextureFormat.RFloat);

            moistureOut = CreateRT(size, size, RenderTextureFormat.RFloat);
            RenderTexture recomb=CreateRT(size, size, RenderTextureFormat.RFloat);
            Wetness  = CreateRT(size, size, RenderTextureFormat.RFloat);
            wetnessPrev = CreateRT(size, size, RenderTextureFormat.RFloat);
            wetnessOut = CreateRT(size, size, RenderTextureFormat.RFloat);
            // Initialize wetnessPrev to zero
            ClearRT(wetnessPrev, 0f);

            RainMap = CreateRT(size, size, RenderTextureFormat.RFloat);
            // Initialize moisturePrev from input
            int kInit = shader.FindKernel("CS_InitMoisture");
            shader.SetInt("Width", size);
            shader.SetInt("Height", size);
            shader.SetTexture(kInit, "MoistureInput", MoistureInput);
            shader.SetTexture(kInit, "MoisturePrev", moisturePrev);

            int gx = Mathf.CeilToInt(size / 8f);
            int gy = Mathf.CeilToInt(size / 8f);
            shader.Dispatch(kInit, gx, gy, 1);

            // Set Common Params
            shader.SetInt("Width", size);
            shader.SetInt("Height", size);

            shader.SetFloat("StepSize", stepSize);
            shader.SetFloat("AdvectionStrength", advectionStrength);

            shader.SetFloat("ValleyPull", valleyPull);
            shader.SetFloat("RainShadowStrength", rainShadowStrength);
            shader.SetFloat("Evaporation", evaporation);
            shader.SetFloat("HeightInfluence", heightInfluence);

            shader.SetFloat("MoistureMin", moistureMin);
            shader.SetFloat("MoistureMax", moistureMax);
            shader.SetFloat("CondensationThreshold", condensationThreshold);
            shader.SetFloat("PrecipitationRate", precipitationRate);
            shader.SetFloat("ValleyRainBoost", valleyRainBoost);
            shader.SetFloat("RainShadowSuppression", rainShadowSuppression);
            shader.SetFloat("PrecipToWetness", precipToWetness);
            shader.SetFloat("MoistureToWetness", moistureToWetness);
            shader.SetFloat("DrainageStrength", drainageStrength);
            shader.SetFloat("ValleyRetention", valleyRetention);
            shader.SetFloat("EvaporationRate", evaporationRate);

            shader.SetFloat("WetnessMin", wetnessMin);
            shader.SetFloat("WetnessMax", wetnessMax);

            shader.SetInt("DebugMode", (int)debugMode);
            int kAdv = shader.FindKernel("CS_AdvectMoisture");
            int kDebug = shader.FindKernel("CS_DebugMoisture");

            shader.SetTexture(kAdv, "FlowMap", WindFlowMap.FlowMap);
            shader.SetTexture(kAdv, "Heightmap", WindFlowMap.HeightMap);
            shader.SetTexture(kAdv, "Curvature", WindFlowMap.Curvature);
            shader.SetTexture(kAdv, "OcclusionMask", WindFlowMap.Occulsion);

            shader.SetTexture(kAdv, "MoisturePrev", moisturePrev);
            shader.SetTexture(kAdv, "MoistureOut", moistureOut);
            shader.SetTexture(kAdv, "Precipitation", RainMap);


            // Multi-step semi-Lagrangian advection
            for (int i = 0; i < iterations; i++)
            {
                shader.Dispatch(kAdv, gx, gy, 1);
                Graphics.CopyTexture(moistureOut, moisturePrev);
            }

            // Final moisture map
            Graphics.CopyTexture(moistureOut, MoistureOutput);

            int kWet = shader.FindKernel("CS_UpdateWetness");

            shader.SetTexture(kWet, "Heightmap", WindFlowMap.HeightMap);
            shader.SetTexture(kWet, "Curvature", WindFlowMap.Curvature);
            shader.SetTexture(kWet, "MoistureOut", MoistureOutput);
            shader.SetTexture(kWet, "Precipitation", RainMap);
            shader.SetTexture(kWet, "WetnessPrev", wetnessPrev);
            shader.SetTexture(kWet, "WetnessOut", wetnessOut);
            for (int i = 0; i < iterations; i++)
            {
                shader.Dispatch(kWet, gx, gy, 1);
                Graphics.CopyTexture(wetnessOut, wetnessPrev);
            }

            Graphics.CopyTexture(wetnessOut, Wetness);

            int kCombine = shader.FindKernel("CS_CombineMoisture");
            shader.SetTexture(kCombine, "MoistureInput", MoistureInput);
            shader.SetTexture(kCombine, "MoistureOut", MoistureOutput);
            shader.SetTexture(kCombine, "RecombinationOut", recomb);
            shader.SetTexture(kCombine, "OcclusionMask", WindFlowMap.Occulsion);
            shader.SetFloat("Recombination", recombFactor);
            shader.Dispatch(kCombine, gx, gy, 1);

            Graphics.CopyTexture(recomb, MoistureOutput);
            // Debug visualization
            if (debugMode > 0 && debugMode != eDebugViz.precipitation)
            {
                shader.SetTexture(kDebug, "FlowMap", WindFlowMap.FlowMap);
                shader.SetTexture(kDebug, "MoistureOut", MoistureOutput);
                shader.SetTexture(kDebug, "DebugOut", debugOutput);
                shader.Dispatch(kDebug, gx, gy, 1);
                preview = ToPreviewTexture(debugOutput, 300);
            }
            if(debugMode==eDebugViz.precipitation)
            {
                preview = ToPreviewTexture(Wetness, 300);
            }

            


        }
    }
}
