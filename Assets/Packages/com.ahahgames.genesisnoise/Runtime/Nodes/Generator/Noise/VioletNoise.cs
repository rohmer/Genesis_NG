using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The VioletNoise node generates deterministic, sampler-free violet-noise-style masks in 2D, 3D, or Cube space.
Violet noise emphasizes very high-frequency variation and suppresses broad structure more aggressively than blue noise, making it useful for:
- Fine dithering
- Stochastic sampling jitter
- High-detail procedural breakup
- Grain and shimmer masks
- Edge-like random texture detail
The node supports frequency, seed, output range, tiling, custom UVs, and multi-channel evaluation.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Violet Noise")]
    public class VioletNoise : FixedNoiseNode
    {
        public override string name => "Violet Noise";

        public override string ShaderName => "Hidden/Genesis/VioletNoise";
    }
}
