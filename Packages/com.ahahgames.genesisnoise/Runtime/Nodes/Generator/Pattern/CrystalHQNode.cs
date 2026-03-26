using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
This is the Crystal HQ node you’ll use for:
- Ice
- Minerals
- Rock
- Stylized crystals
- Gemstone breakup
- Terrain
- Organic crystalline structures
- High‑frequency detail masks
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Crystal HQ")]
    public class CrystalHQNode : FixedNoiseNode
    {
        public override string name => "Crystal HQ";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/CrystalHQ";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}