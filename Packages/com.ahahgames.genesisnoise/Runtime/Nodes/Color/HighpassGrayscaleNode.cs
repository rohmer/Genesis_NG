using GraphProcessor;

using System.Collections.Generic;

using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
[Documentation(@""
This node:
Blurs the input (usually Gaussian)

Subtract blurred from original

Normalize / remap

Optional contrast boost
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
