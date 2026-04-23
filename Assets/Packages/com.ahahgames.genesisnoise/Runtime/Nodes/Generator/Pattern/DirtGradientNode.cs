using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
A Genesis Noise shader node that produces a vertical dirt gradient (dark at top → light at bottom) blended with procedural dirt: multi‑scale FBM, speckle, splatter, domain warp, curvature/AO bias, and debug outputs. The gradient is controllable (curve, falloff, invert) and tile‑safe for CRT render textures.
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Dirt Gradient")]
    public class DirtGradientNode : FixedNoiseNode
    {
        public override string name => "Dirt Gradient";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/DirtGradient";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}