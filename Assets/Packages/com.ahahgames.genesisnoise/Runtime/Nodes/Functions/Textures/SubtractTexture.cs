using GraphProcessor;

using System;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Subtracts one texture input from another per pixel.
")]

    [System.Serializable, NodeMenuItem("Function/Texture/Texture Subtraction")]
    public class SubtractTextureNode : TextureMathNode
    {
        public override string name => "Texture Division";
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
            if (inputA != null)
            {
                if (inputB == null)
                {
                    Graphics.Blit(inputA, (RenderTexture)output);
                    preview = ToPreviewTexture((RenderTexture)output);
                    return true;
                }

            }
            if (inputA == null && inputB == null)
                return true;
            shader = Resources.Load<ComputeShader>("Shaders/Functions/Math/TextureDivision");

            int kernel = shader.FindKernel("CSMain");
            shader.SetTexture(kernel, "inputA", inputA);
            shader.SetTexture(kernel, "output", output);
            if (inputB is RenderTexture)
            {
                shader.SetTexture(kernel, "inputB", (RenderTexture)inputB);
                shader.SetInt("mathType", 0);
            }
            if (inputB is float || inputB is int || inputB is bool)
            {
                shader.SetFloat("floatInput", (float)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.FLOAT));
                shader.SetInt("mathType", 1);
            }
            // Deal with vector types
            if (inputB is Vector2 || inputB is Vector2Int)
            {
                Vector2 v = (Vector2)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR2);
                shader.SetFloats("vectorInput", new float[] { v.x, v.y, 0, 0 });
                shader.SetInt("mathType", 2);
            }
            if (inputB is Vector3 || inputB is Vector3Int)
            {
                Vector3 v = (Vector3)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR3);
                shader.SetFloats("vectorInput", new float[] { v.x, v.y, v.z, 0 });
                shader.SetInt("mathType", 2);
            }
            if (inputB is Vector4)
            {
                Vector4 v = (Vector4)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.VECTOR4);
                shader.SetFloats("vectorInput", new float[] { v.x, v.y, v.z, v.w });
                shader.SetInt("mathType", 2);
            }
            if (inputB is Color)
            {
                Color v = (Color)TypeCaster.ToType(inputB, TypeCaster.genesisTypes.COLOR);
                shader.SetFloats("vectorInput", new float[] { v.r, v.g, v.b, v.a });
                shader.SetInt("mathType", 2);
            }
            shader.SetTexture(kernel, "inputB", inputA);
            int size = Mathf.CeilToInt(inputA.width / 8f); shader.Dispatch(kernel,size,size,1);
            preview = ToPreviewTexture((RenderTexture)output);
            return r;
        }

    }

}
