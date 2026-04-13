using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a dirt-style grunge pattern for surface breakup, masking, and worn material detail.
")]

[System.Serializable, NodeMenuItem("Generators/Pattern/Dirt 1")]
    public class DirtNode : FixedNoiseNode
    {
        public override string name => "Dirt";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/GrungeDirt";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}
