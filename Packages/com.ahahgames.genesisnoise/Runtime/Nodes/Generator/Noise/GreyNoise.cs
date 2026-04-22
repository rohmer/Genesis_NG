using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The GreyNoise node generates deterministic, sampler-free grey noise in 2D, 3D, or Cube space.
Grey noise uses a balanced, equalized spread of octaves so no single frequency band dominates, making it useful for:
- General-purpose procedural masks
- Balanced terrain and material breakup
- Density fields
- Stochastic sampling weights
- Natural variation without strong low- or high-frequency bias
The node supports frequency, octaves, lacunarity, high-frequency lift, seed, output range, tiling, custom UVs, and multi-channel evaluation.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Grey Noise")]
    public class GreyNoise : FixedNoiseNode
    {
        public override string name => "Grey Noise";

        public override string ShaderName => "Hidden/Genesis/GreyNoise";
    }
}
