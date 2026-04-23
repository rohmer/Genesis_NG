using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
    Soft, billowy fractal noise.
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Clouds 1")]
    public class Clouds1Node: FixedNoiseNode
    {
        public override string name => "Clouds 1";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Clouds1";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}