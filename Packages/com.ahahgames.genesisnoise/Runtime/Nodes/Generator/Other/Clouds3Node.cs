using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
    Chunky, blotchy with marble like swirls
")]

    [System.Serializable, NodeMenuItem("Generators/Other/Clouds 3")]
    public class Clouds3Node : FixedNoiseNode
    {
        public override string name => "Clouds 3";
        public override string NodeGroup => "Generators";
        public override string ShaderName => "Hidden/Genesis/Clouds3";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}