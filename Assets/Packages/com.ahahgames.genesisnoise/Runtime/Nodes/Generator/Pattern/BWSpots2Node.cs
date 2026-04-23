using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
    Black and white spots pattern. The spots are more circular than in the BW Spots node, but they are also more regular. The pattern is tileable.
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/BW Spots 2")]
    public class BWSpots2Node : FixedNoiseNode
    {
        public override string name => "BW Spots 2";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/BWSpots2";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}