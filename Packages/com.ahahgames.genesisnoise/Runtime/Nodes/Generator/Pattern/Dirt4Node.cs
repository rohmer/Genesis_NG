using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a fourth dirt-style grunge variant for adding irregular debris and breakup.
")]

[System.Serializable, NodeMenuItem("Generators/Pattern/Dirt 4")]
    public class Dirt4Node : FixedNoiseNode
    {
        public override string name => "Dirt 4";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/GrungeDirt4";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}
