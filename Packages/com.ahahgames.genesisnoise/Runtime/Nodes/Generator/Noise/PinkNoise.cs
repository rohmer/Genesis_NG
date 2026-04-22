using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The PinkNoise node generates deterministic, sampler-free pink noise in 2D, 3D, or Cube space.
Pink noise emphasizes broad, low-frequency variation while retaining fine detail, making it useful for:
- Terrain and cloud masks
- Organic breakup
- Weathering variation
- Soft clustered randomness
- Procedural material detail
The node supports frequency, octaves, lacunarity, amplitude falloff, seed, output range, tiling, custom UVs, and multi-channel evaluation.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Pink Noise")]
    public class PinkNoise : FixedNoiseNode
    {
        public override string name => "Pink Noise";

        public override string ShaderName => "Hidden/Genesis/PinkNoise";
    }
}
