using GraphProcessor;

using System.Collections.Generic;

using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Extracts high-frequency detail from the input by blurring it, subtracting the blurred result from the original, and remapping the difference into a grayscale result.

Use this to build detail masks, sharpen monochrome data, or isolate fine surface variation.
")]

[System.Serializable, NodeMenuItem("Color/Highpass Grayscale")]
    public class HighpassGrayscaleNode : FixedShaderNode
    {
        public override string name => "Highpass Grayscale";

        public override string ShaderName => "Hidden/Genesis/HighpassGrayscale";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Color";
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Algorithm" };
        public override float nodeWidth => 300f;
        protected override bool ProcessNode(CommandBuffer cmd)
        {
            bool r = base.ProcessNode(cmd);

            return r;
        }
    }
}

