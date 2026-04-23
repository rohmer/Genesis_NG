using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The BrownianNoise node generates deterministic, sampler-free Brownian noise in 2D, 3D, or Cube space.
Brownian noise strongly favors lower frequencies, producing broad smooth variation with subdued fine detail. It is useful for:
- Large terrain and cloud forms
- Soft erosion and weathering masks
- Organic clustered breakup
- Slow material variation
- Low-frequency procedural displacement
The node supports frequency, octaves, lacunarity, high-frequency falloff, seed, output range, tiling, custom UVs, and multi-channel evaluation.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Brownian Noise")]
    public class BrownianNoise : FixedNoiseNode
    {
        public override string name => "Brownian Noise";

        public override string ShaderName => "Hidden/Genesis/BrownianNoise";
    }
}
