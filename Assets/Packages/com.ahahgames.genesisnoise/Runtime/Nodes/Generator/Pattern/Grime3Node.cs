using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a third grime pattern variant for layered dirt buildup and irregular masking.
")]

[System.Serializable, NodeMenuItem("Generators/Pattern/Grime 3")]
    public class Grime3Node : FixedNoiseNode
    {
        public override string name => "Grime 3";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Grunge003";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}
