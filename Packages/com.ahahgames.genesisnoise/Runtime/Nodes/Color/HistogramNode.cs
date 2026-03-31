using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Color/Histogram")]
    public class HistogramNode : FixedShaderNode
    {
        public override string name => "Histogram";

        public override string ShaderName => "Hidden/Genesis/Histogram";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => 325;

        public override bool hasPreview => true;
    }
}