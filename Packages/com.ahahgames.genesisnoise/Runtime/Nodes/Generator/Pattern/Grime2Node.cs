using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Grime 2")]
    public class Grime2Node : FixedNoiseNode
    {
        public override string name => "Grime 2";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Grunge002";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}