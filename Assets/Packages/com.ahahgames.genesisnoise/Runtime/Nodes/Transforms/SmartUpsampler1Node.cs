using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Smart Upsampler 1 takes a low‑resolution noise and reconstructs a higher‑resolution version that preserves the character of the original while adding subtle detail. It’s not just bilinear or bicubic; it’s a content‑aware upscale that:
✔ Reconstructs sharper edges
✔ Preserves noise structure
✔ Adds micro‑detail
✔ Avoids blur and ringing
✔ Works for grayscale or color
")]

    [System.Serializable, NodeMenuItem("Transform/Smart Upsampler 1")]
    public class SmartUpsampler1Node : FixedNoiseNode
    {
        public override string name => "Smart Upsampler 1";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/NoiseUpscale1";
    }
}