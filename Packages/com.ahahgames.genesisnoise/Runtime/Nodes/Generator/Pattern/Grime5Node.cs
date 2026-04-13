using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a fifth grime pattern variant for adding aged surface breakup and dirt clustering.
")]

[System.Serializable, NodeMenuItem("Generators/Pattern/Grime 5")]
    public class Grime5Node : FixedNoiseNode
    {
        public override string name => "Grime 5";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Grunge005";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}
