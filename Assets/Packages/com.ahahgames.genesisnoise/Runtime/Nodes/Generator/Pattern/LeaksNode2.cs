using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Heavier leak origins (bigger blotches)
- Chaotic streak breakup
- Directional tearing
- Micro‑drips
- Turbulent flow
- More contrast and edge variation

")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Leaks 2")]
    public class LeaksNode2 : FixedNoiseNode
    {
        public override string name => "Leaks 2";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/GrungeLeaks2";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}