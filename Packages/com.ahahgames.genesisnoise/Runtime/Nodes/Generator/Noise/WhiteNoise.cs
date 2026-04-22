using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The WhiteNoise node generates deterministic, sampler-free white noise in 2D, 3D, or Cube space.
It is a lightweight noise source ideal for:
- Random masks
- Dithering
- Stochastic sampling
- Pattern breakup
- Randomized FX
- Seeded variation
- Debugging procedural graphs
The node supports frequency, seed, output range, tiling, custom UVs, and multi-channel evaluation.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/White Noise")]
    public class WhiteNoise : FixedNoiseNode
    {
        public override string name => "White Noise";

        public override string ShaderName => "Hidden/Genesis/WhiteNoise";
    }
}

