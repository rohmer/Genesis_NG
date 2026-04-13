using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a third dirt-style grunge variant with alternate breakup for worn surface detail.
")]

[System.Serializable, NodeMenuItem("Generators/Pattern/Dirt 3")]
    public class Dirt3Node : FixedNoiseNode
    {
        public override string name => "Dirt 3";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/GrungeDirt3";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}
