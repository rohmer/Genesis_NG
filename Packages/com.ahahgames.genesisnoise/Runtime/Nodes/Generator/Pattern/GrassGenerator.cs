using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Grass")]
    public class GrassNode : FixedNoiseNode
    {
        public override string name => "Grass";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Grass";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 500;
    }
}