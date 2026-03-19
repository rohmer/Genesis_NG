using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
✔ Leak origins
Large Gaussian blotches where leaks begin.
✔ Vertical streaking
Directional drips that feel like gravity‑pulled grime.
✔ Turbulent breakup
Irregular, dirty, organic edges.
✔ Flow drift
Soft downward motion like wet grime.
")]

    [System.Serializable, NodeMenuItem("Generators/Other/Leaks 1")]
    public class LeaksNode1 : FixedNoiseNode
    {
        public override string name => "Leaks 1";
        public override string NodeGroup => "Generators";
        public override string ShaderName => "Hidden/Genesis/GrungeLeaks1";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}