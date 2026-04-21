using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Edge detection using one of a few different algorithms
")]

    [System.Serializable, NodeMenuItem("Filters/Edge Detect/Edge Detection")]
    public class EdgeDetectionNode : FixedShaderNode
    {
        public override string name => "Edge Detection";

        public override string ShaderName => "Hidden/Genesis/EdgeDetection";
        public override string NodeGroup => "Operations";
        public override bool DisplayMaterialInspector => true;

    }
}