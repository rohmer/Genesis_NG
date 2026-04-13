using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a ninth grime pattern variant for layered dirty masks and worn material detail.
")]

[System.Serializable, NodeMenuItem("Generators/Pattern/Grime 9")]
    public class Grime9Node : FixedNoiseNode
    {
        public override string name => "Grime 9";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Grunge009";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}
