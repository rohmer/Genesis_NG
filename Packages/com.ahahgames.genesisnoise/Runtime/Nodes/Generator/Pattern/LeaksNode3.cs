using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
• 	slower, heavier drips
• 	multi‑scale flow fields
• 	plateaus of wetness that pool before dripping
• 	directional gravity bias but with turbulence
• 	layered stain halos and micro‑veins
")]

    [System.Serializable, NodeMenuItem("Generators/Other/Leaks 3")]
    public class LeaksNode3 : FixedNoiseNode
    {
        public override string name => "Leaks 3";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/GrungeLeaks3";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}