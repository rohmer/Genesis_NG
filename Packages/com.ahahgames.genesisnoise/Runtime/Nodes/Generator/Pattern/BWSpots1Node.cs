using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
    Simulates an Aurora
")]

    [System.Serializable, NodeMenuItem("Generators/Other/BW Spots 1")]
    public class BWSpots1Node : FixedNoiseNode
    {
        public override string name => "BW Spots 1";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/BWSpots";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}