using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
A configurable multi‑octave fractal noise engine  
with controls for:
octaves, lacunarity, gain, offset, amplitude, roughness, and seed.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Fractal Sum Base")]
    public class FractalSumBaseNode : FixedNoiseNode
    {
        public override string ShaderName => "Hidden/Genesis/FractalSumBase";

        public override string name => "Fractal Sum Base";
        public override string NodeGroup => "Noise";
    }
}