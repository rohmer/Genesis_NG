using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates classic fractal Brownian motion noise by layering Perlin noise across multiple octaves.

Use this node when you want a simpler, dedicated FBM generator with direct control over frequency, octaves, persistence, lacunarity, seed, and output range.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Fractal Brownian Motion")]
    public class FractalBrownianMotionNoiseNode : FixedNoiseNode
    {
        public override string name => "Fractal Brownian Motion";
        public override string NodeGroup => "Noise";
        public override string ShaderName => "Hidden/Genesis/FractalBrownianMotionNoise";
    }
}
