using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The VelvetNoise node generates deterministic, sampler-free velvet noise in 2D, 3D, or Cube space.
Velvet noise is a sparse field of random impulses, making it useful for:
- Fine grains and flecks
- Sparse stochastic masks
- Sampling impulse patterns
- Material speckle
- Procedural sparkle or grit
- Discontinuous breakup
The node supports frequency, impulse density, impulse radius, softness, seed, output range, tiling, custom UVs, and multi-channel evaluation.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Velvet Noise")]
    public class VelvetNoise : FixedNoiseNode
    {
        public override string name => "Velvet Noise";

        public override string ShaderName => "Hidden/Genesis/VelvetNoise";
    }
}
