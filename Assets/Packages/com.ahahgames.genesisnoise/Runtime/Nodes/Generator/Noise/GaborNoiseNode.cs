using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Sparse-convolution Gabor noise for brushed, fibrous, scratchy, and directional surface breakup.

Gabor noise is especially useful as a foundational material primitive because it can cover:
- Fibers and hairline streaks
- Brushed metal and anisotropic breakup
- Paper, cloth, and directional grain
- Scratch masks and fine weathering detail
")]
    [System.Serializable, NodeMenuItem("Generators/Noise/Gabor Noise")]
    public class GaborNoiseNode : FixedNoiseNode
    {
        public override string name => "Gabor Noise";
        public override string ShaderName => "Hidden/Genesis/GaborNoise";
        public override string NodeGroup => "Noise";
    }
}
