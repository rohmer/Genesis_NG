using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The BlueNoise node generates deterministic, sampler-free blue-noise-style masks in 2D, 3D, or Cube space.
Blue noise suppresses low-frequency clustering and keeps randomness concentrated in fine detail, making it useful for:
- Dithering
- Stochastic sampling
- Procedural scattering
- Pattern breakup
- Anti-aliasing
- Poisson-like distributions
The node supports frequency, seed, output range, tiling, custom UVs, and multi-channel evaluation.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Blue Noise")]
    public class BlueNoise : FixedNoiseNode
    {
        public override string name => "Blue Noise";

        public override string ShaderName => "Hidden/Genesis/BlueNoise";
    }
}
