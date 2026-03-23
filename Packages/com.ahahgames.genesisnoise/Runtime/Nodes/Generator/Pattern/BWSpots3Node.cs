using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
    Simulates an Aurora
")]

    [System.Serializable, NodeMenuItem("Generators/Other/BW Spots 3")]
    public class BWSpots3Node : FixedNoiseNode
    {
        public override string name => "BW Spots 3";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/BWSpots3";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}