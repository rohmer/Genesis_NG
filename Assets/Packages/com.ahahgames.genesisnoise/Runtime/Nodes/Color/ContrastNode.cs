using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Adjusts the contrast of the source color by modifying its saturation and luminosity components.
")]

    [System.Serializable, NodeMenuItem("Color/Contrast")]
    public class ContrastNode : FixedShaderNode
    {
        public override string name => "Contrast";
        public override string NodeGroup => "Color";

        public override string ShaderName => "Hidden/Genesis/Contrast";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { };
    }
}
