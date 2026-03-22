using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Smart Upsampler 2 is the natural evolution of Noise Upscale 1 — sharper, more contrast‑preserving, and more structure‑aware. 

")]

    [System.Serializable, NodeMenuItem("Transform/Smart Upsampler 2")]
    public class SmartUpsampler2Node : FixedNoiseNode
    {
        public override string name => "Smart Upsampler 2";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/NoiseUpscale2";
    }
}