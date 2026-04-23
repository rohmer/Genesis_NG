using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Blur the input texture using a Gaussian filter in the specified direction.

Note that the kernel uses a fixed number of 32 samples, for high blur radius you may need to use two directional blur nodes.
")]

    [System.Serializable, NodeMenuItem("Filters/Blur/Directional Gaussian Blur")]
    public class DirectionalGaussianBlurNode : FixedShaderNode
    {
        public override string name => "Directional Gaussian Blur";
        public override string NodeGroup => "Blur";
        public override string ShaderName => "Hidden/Genesis/DirectionalGaussianBlur";

        public override bool DisplayMaterialInspector => true;
    }
}