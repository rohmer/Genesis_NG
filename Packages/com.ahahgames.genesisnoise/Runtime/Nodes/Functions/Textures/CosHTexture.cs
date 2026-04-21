using GraphProcessor;

using System;

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Windows;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Applies `COSH(A)` to the source texture per pixel.
")]

    [System.Serializable, NodeMenuItem("Function/Texture/Texture COSH(A)")]
    public class CosHTextureNode : GenesisNode
    {
        [Input(name = "A")]
        public RenderTexture inputA;

        [Output(name = "Output")]
        public RenderTexture output;

        protected ComputeShader shader = null;
        public override string name => "Texture COSH(A)";
        public override string NodeGroup => "Texture";

        public override bool showDefaultInspector => false;
        public override bool hasPreview => true;
        public override float nodeWidth => 300;
        internal Texture2D preview;
        public override Texture previewTexture => preview;

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

        protected override void Enable()
        {
            base.Enable();
            preview = new Texture2D(300, 300);
            output = CreateRT(this.graph.settings.width, this.graph.settings.height, RenderTextureFormat.ARGBFloat);
            preview = new Texture2D(300, 300);
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

            if (inputA == null)
                return true;
            shader = Resources.Load<ComputeShader>("Shaders/Functions/Math/TextureCOSH");

            int kernel = shader.FindKernel("CSMain");
            shader.SetTexture(kernel, "inputA", inputA);
            shader.SetTexture(kernel, "output", output);

            int size = Mathf.CeilToInt(inputA.width / 8f); shader.Dispatch(kernel,size,size,1);
            preview = ToPreviewTexture((RenderTexture)output);
            return r;
        }

    }

}
