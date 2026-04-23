using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a second dirt-style grunge variant for layered surface breakup and masking.
")]

[System.Serializable, NodeMenuItem("Generators/Pattern/Dirt 2")]
    public class Dirt2Node : FixedNoiseNode
    {
        public override string name => "Dirt 2";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/GrungeDirt2";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}
