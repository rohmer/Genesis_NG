using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Takes any input texture
- Applies exposure compensation (photographic EV)
- Uses the correct formula:
\mathrm{color_{\mathnormal{out}}}=\mathrm{color_{\mathnormal{in}}}\cdot 2^{\mathrm{exposure}}- Includes contrast and bias shaping for artistic control
")]

    [System.Serializable, NodeMenuItem("Color/Exposure")]
    public class ExposureNode : FixedShaderNode
    {
        public override string name => "Exposure";
        public override string NodeGroup => "Color";

        public override string ShaderName => "Hidden/Genesis/Exposure";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { };
    }
}
