using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Multi-Kernel size Gaussian blur
")]

    [System.Serializable, NodeMenuItem("Filters/Blur/Gaussian Blur")]
    public class GaussianBlurNode : FixedNoiseNode
    {
        public override string name => "Gaussian Blur";
        public override string NodeGroup => "Blur";
        public override string ShaderName => "Hidden/Genesis/GaussianBlur";
    }
}