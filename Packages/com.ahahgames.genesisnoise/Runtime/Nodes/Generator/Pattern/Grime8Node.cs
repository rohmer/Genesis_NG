using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Grime 8")]
    public class Grime8Node : FixedNoiseNode
    {
        public override string name => "Grime 8";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Grunge008";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}