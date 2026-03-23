using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Other/Grime 4")]
    public class Grime4Node : FixedNoiseNode
    {
        public override string name => "Grime 4";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Grunge004";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}