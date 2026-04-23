using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Apply a Scale and Bias on the input texture color.
")]

    [System.Serializable, NodeMenuItem("Color/Scale & Bias")]
    public class ScaleBiasNode : FixedShaderNode
    {
        public override string name => "Scale & Bias";

        public override string ShaderName => "Hidden/Genesis/ScaleBias";

        public override bool DisplayMaterialInspector => true;

        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Mode" };

        public override string NodeGroup => "Color";

    }
}