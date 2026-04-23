using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Larger, softer Gaussian blobs
- Smooth watercolor halos
- Gentle warp for organic diffusion
- More painterly gradients
- Less “grainy,” more “cloud‑like”
- Perfect for stylized masks, roughness breakup, watercolor textures
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Gaussian Spots 2")]
    public class GaussianSpots2 : FixedNoiseNode
    {
        public override string name => "Gaussian Spots 2";
        public override string NodeGroup => "Shapes";
        public override string ShaderName => "Hidden/Genesis/GaussianSpots2";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}