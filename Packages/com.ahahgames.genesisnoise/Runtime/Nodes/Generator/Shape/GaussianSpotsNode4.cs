using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Ink‑bloom diffusion
- Soft volumetric halos
- Gentle flow drift
- Turbulent breakup
- Micro‑bloom sparkles
- Painterly, atmospheric gradients
It’s the most ink‑like and diffusive variant so far — perfect for watercolor, stylized shading, roughness breakup, or organic masks.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Gaussian Spots 4")]
    public class GaussianSpots4 : FixedNoiseNode
    {
        public override string name => "Gaussian Spots 4";
        public override string NodeGroup => "Shapes";
        public override string ShaderName => "Hidden/Genesis/GaussianSpots4";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}