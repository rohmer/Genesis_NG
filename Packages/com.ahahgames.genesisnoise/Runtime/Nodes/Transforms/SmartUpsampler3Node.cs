using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Smart Upsampler 3 is the big-boy variant
✔ Ultra‑sharp reconstruction
✔ High‑frequency detail preservation
✔ Multi‑octave micro‑structure
✔ Stronger contrast shaping
✔ A more “procedural” upscale rather than photographic

")]

    [System.Serializable, NodeMenuItem("Transform/Smart Upsampler 3")]
    public class SmartUpsampler3Node : FixedNoiseNode
    {
        public override string name => "Smart Upsampler 3";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/NoiseUpscale3";
    }
}