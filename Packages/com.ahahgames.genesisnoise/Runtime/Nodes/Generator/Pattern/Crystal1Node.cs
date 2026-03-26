using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Produces:
- Crystal facets
- Mineral breakup
- Angular cell edges
- Hard or soft crystalline patterns
- Perfect for stone, ice, minerals, stylized surfaces
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Crystal 1")]
    public class Crystal1Node : FixedNoiseNode
    {
        public override string name => "Crystal 1";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Crystal1";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}