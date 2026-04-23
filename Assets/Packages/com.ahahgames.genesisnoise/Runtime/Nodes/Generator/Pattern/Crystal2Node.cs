using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Worley F1, F2, F3
- A facet intensity function based on
(F3−𝐹1)
- Much sharper, more geometric edges
= Stronger contrast between facets
- More mineral‑like angularity
- Optional ridge shaping
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Crystal 2")]
    public class Crystal2Node : FixedNoiseNode
    {
        public override string name => "Crystal 2";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Crystal2";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}