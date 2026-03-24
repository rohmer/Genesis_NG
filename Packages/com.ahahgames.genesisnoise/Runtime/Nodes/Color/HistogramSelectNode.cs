using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
It’s basically a smart range selector that:
- Finds a value range inside the histogram
- Lets you slide that range across the histogram
- Lets you adjust width, position, and contrast
- Outputs a clean 0–1 mask
It’s like Histogram Scan + Histogram Range, but with a movable window that selects a slice of the histogram.
")]

    [System.Serializable, NodeMenuItem("Color/Histogram Select")]
    public class HistogramSelectNode : FixedShaderNode
    {
        public override string name => "Histogram Select";

        public override string ShaderName => "Hidden/Genesis/HistogramSelect";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => 325;

        public override bool hasPreview => true;
    }
}