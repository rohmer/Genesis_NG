using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generate white noise.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/White Noise")]
    public class WhiteNoise : FixedShaderNode
    {
        public override string name => "White Noise";

        public override string NodeGroup => "Noise";

        public override string ShaderName => "Hidden/Genesis/WhiteNoise";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { };



    }
}

