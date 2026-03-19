using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;


using System;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{
    [Serializable, NodeMenuItem("Terrain/Biome/Water Level")]
    public class WaterLevelNode : GenesisNode
    {
        [Input(name = "Height Map")]
        public HeightField TerrainInput;

        [Output(name = "Water Level")]
        public float WaterLevel;

        public override string name => "Water Level";
        public override bool showDefaultInspector => false;
        public override bool hasPreview => true;
        public override bool hasSettings => false;
        public override float nodeWidth => 300;
        public override string NodeGroup => "Biomes";
        public override Texture previewTexture => preview;

        internal Texture2D preview;

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

        internal void GeneratePreview()
        {
            ComputeShader shader = Resources.Load<ComputeShader>("Shaders/WaterLevelPreview");
            int kernel = shader.FindKernel("CSMain");
            shader.SetTexture(kernel, "_HeightMap", TerrainInput.HeightMap);

            RenderTexture pRT = CreateRT(TerrainInput.mapSize, TerrainInput.mapSize, RenderTextureFormat.ARGB32);
            shader.SetFloat("_WaterLevel", WaterLevel);
            shader.SetTexture(kernel, "_Preview", pRT);
            shader.SetInts("_TexSize", TerrainInput.mapSize, TerrainInput.mapSize);

            int v = Mathf.CeilToInt(TerrainInput.mapSize / 8f);
            shader.Dispatch(kernel, v, v, 1);
            preview = ToPreviewTexture(pRT);
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            bool r = base.ProcessNode(cmd);
            if (TerrainInput == null)
                return r;

            GeneratePreview();
            return r;
        }

    }
}
