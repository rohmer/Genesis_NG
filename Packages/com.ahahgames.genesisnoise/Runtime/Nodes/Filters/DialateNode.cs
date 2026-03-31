using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
performs morphological dilation on a feature mask derived from the source texture. It supports binary dilation (thresholded luminance) and grayscale dilation (max filter on luminance), iterative dilation (multiple passes), and a simple color expansion strategy that expands feature colors into the dilated region
")]

    [System.Serializable, NodeMenuItem("Filters/Dialate")]
    public class DialateNode : FixedNoiseNode
    {
        public override string name => "Dialate";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/Dilate";
    }
}