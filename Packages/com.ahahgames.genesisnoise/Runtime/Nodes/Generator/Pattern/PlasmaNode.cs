using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
It’s not just “FBM” and not just “noise turbulence”—it’s a fractal interference pattern built from:
- Two or more layered noise fields
- Different frequencies
- Phase offsets
- Additive + subtractive interference
- Optional color remapping
- Soft, electric, cloudy, nebula‑like structures
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Plasma")]
    public class PlasmaNode : FixedNoiseNode
    {
        public override string name => "Plasma";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Plasma";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}