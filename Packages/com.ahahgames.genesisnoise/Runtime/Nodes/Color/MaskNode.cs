using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Sample the target texture and mask it using input texture. Note that the mask is written in the alpha channel of the output.
")]

    [System.Serializable, NodeMenuItem("Color/Mask")]
    public class MaskNode : FixedShaderNode
    {
        public override string name => "Mask";

        public override string ShaderName => "Hidden/Genesis/Mask";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Color";

        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Mask" };
    }
}