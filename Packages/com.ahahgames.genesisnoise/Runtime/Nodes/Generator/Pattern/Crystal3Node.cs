using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Crystal 3 is less about hard mineral edges and more about:
- Rounded crystalline blobs
- Soft transitions
- Organic mineral deposits
- Clay‑like cellular breakup
- Smooth Worley‑derived gradients
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Crystal 3")]
    public class Crystal3Node : FixedNoiseNode
    {
        public override string name => "Crystal 3";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Crystal3";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}