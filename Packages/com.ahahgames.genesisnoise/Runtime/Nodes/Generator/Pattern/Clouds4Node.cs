using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
    Stretched directional noise.
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Clouds 4")]
    public class Clouds4Node : FixedNoiseNode
    {
        public override string name => "Clouds 4";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Clouds4";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}