using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Large, soft, drifting blobs
- Directional smear (anisotropic stretch)
- Watercolor‑like diffusion
- Soft turbulence
- Painterly gradients
- Less “dots,” more “organic patches”
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Gaussian Spots 3")]
    public class GaussianSpots3 : FixedNoiseNode
    {
        public override string name => "Gaussian Spots 3";
        public override string NodeGroup => "Shapes";
        public override string ShaderName => "Hidden/Genesis/GaussianSpots3";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}