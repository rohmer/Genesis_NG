using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System.Diagnostics;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.GNTerrain.Nodes
{

    [Documentation(@"
")]

    [System.Serializable, NodeMenuItem("Terrain/Temperature")]
    public class TemperatureNode : GenesisNode
    {
        [SerializeField, Input(name = "Height Map", allowMultiple = false)]
        public HeightField TerrainInput;

        [SerializeField, Output(name = "Temperature Map")]
        public RenderTexture TemperatureMap;

        public override string name => "Temperature Map";
        public override bool showDefaultInspector => false;
        public override bool hasPreview => true;
        public override bool hasSettings => false;
        public override float nodeWidth => 300;
        internal Texture2D preview;
        public override Texture previewTexture => preview;

        public bool ScaleToMapHeight = true;
        public AnimationCurve TemperatureCurve = new AnimationCurve();

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

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (TerrainInput == null)
                return false;
            bool r = base.ProcessNode(cmd);
            createTemp();

            return r;
        }


        public static float[] BakeCurve(AnimationCurve curve, int resolution = 256)
        {
            float[] data = new float[resolution];
            for (int i = 0; i < resolution; i++)
            {
                float t = i / (float)(resolution - 1);
                data[i] = curve.Evaluate(t);
            }
            return data;
        }


        internal void createTemp()
        {
            int size = TerrainInput.mapSize;
            ComputeShader shader = Resources.Load<ComputeShader>("Shaders/Temperature");
            int kernel = shader.FindKernel("CSMain");
            ComputeBuffer curveBuffer;

            float[] curveData = BakeCurve(TemperatureCurve, 2048);
            curveBuffer = new ComputeBuffer(2048, sizeof(float));
            curveBuffer.SetData(curveData);

            TemperatureMap=new RenderTexture(size,size, 0, RenderTextureFormat.RFloat);
            TemperatureMap.enableRandomWrite = true;
            TemperatureMap.Create();
            float scale = 1f;
            if(ScaleToMapHeight)
            {
                ComputeShader maxH = Resources.Load<ComputeShader>("Shaders/MaxHeight");
                int kH = maxH.FindKernel("ComputeMaxHeight");
                maxH.SetTexture(kH, "_HeightMap", TerrainInput.HeightMap);
                maxH.SetFloat("MaxHeight", scale);
                maxH.Dispatch(kH, size / 8, size / 8, 1);
            }
            shader.SetFloat("_Scale", scale);
            shader.SetTexture(kernel, "_HeightMap", TerrainInput.HeightMap);
            shader.SetTexture(kernel, "_TemperatureMap", TemperatureMap);
            shader.SetBuffer(kernel, "_CurveData", curveBuffer);
            shader.SetInt("_CurveResolution", 2048);

            shader.Dispatch(kernel,size/ 8, size/ 8, 1);


            preview = ToPreviewTexture(TemperatureMap, 300);
        }

    }
}
