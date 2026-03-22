using GraphProcessor;

using System;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Converts a grayscale image to a colorized image based on a gradient
")]

    [System.Serializable, NodeMenuItem("Color/Colorize")]
    public class ColorizeNode : FixedShaderNode
    {
        public Texture2D texture;
        public Gradient gradient = new();

        const int TEXTURESIZE = 256;
        public override string name => "Colorize";

        public override string ShaderName => "Hidden/Genesis/Colorize";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Color";
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Gradient" };
        public override float nodeWidth => 300;
        public void UpdateTexture()
        {
            if (texture == null)
            {
                texture = new Texture2D(TEXTURESIZE, 1, TextureFormat.RGBA32, false);
                texture.wrapMode = TextureWrapMode.Clamp;
            }
            texture.filterMode = gradient.mode == GradientMode.Blend ? FilterMode.Bilinear : FilterMode.Point;
            for (int i = 0; i < TEXTURESIZE; i++)
            {
                float t = (float)i / (TEXTURESIZE - 1);
                texture.SetPixel(i, 0, gradient.Evaluate(t));
            }
            texture.Apply();
            try
            {
                material.SetTexture("_Gradient", texture);
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
        }

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            bool r = base.ProcessNode(cmd);

            return r;
        }
    }
}
