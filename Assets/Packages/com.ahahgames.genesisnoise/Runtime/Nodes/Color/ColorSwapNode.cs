using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Replace the source color by the target color in the image.
")]

    [System.Serializable, NodeMenuItem("Color/Replace Color")]
    public class ColorSwapNode : FixedShaderNode
    {
        public override string name => "Swap Color";

        public override string ShaderName => "Hidden/Genesis/ColorSwap";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;

        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Mode" };
    }
}