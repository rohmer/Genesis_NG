using GraphProcessor;

using System.Collections.Generic;

using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Extracts high-frequency color detail from the input by blurring it, subtracting the blurred result from the original, and remapping the difference.

Use this to isolate fine detail before sharpening, blending, or mask creation while preserving color information.
")]

[System.Serializable, NodeMenuItem("Color/Highpass Color")]
    public class HighpassColorNode : FixedShaderNode
    {
        public override string name => "Highpass Color";

        public override string ShaderName => "Hidden/Genesis/HighpassColor";

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
