using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
✔ Preserves edges
✔ Avoids blurring silhouettes
✔ Sharpens structure instead of smearing it
✔ Adds high‑frequency detail only where appropriate
✔ Uses local gradient magnitude to guide reconstruction
This is the perfect companion to your Upscale 1/2/3 family — and it’s exactly the kind of node that makes procedural noise feel hand‑crafted.
")]

    [System.Serializable, NodeMenuItem("Transform/Smart Upsampler Edge Aware")]
    public class SmartUpsamplerEdgeAwareNode : FixedNoiseNode
    {
        public override string name => "Smart Upsampler Edge Aware";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/NoiseUpscale3_EdgeAware";
    }
}