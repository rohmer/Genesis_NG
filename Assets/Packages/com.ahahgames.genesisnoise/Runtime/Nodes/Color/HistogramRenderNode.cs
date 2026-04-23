using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Compute a histogram of the input grayscale
- Normalize it
- Render it as a bar graph
- Optional log scale
- Optional smoothing
- Optional cumulative mode
This version gives you:
- 256‑bin histogram
- Linear or log scale
- Optional smoothing
- Optional cumulative histogram
- Adjustable bar width
- Adjustable intensity
- Fully deterministic

")]

    [System.Serializable, NodeMenuItem("Color/Histogram Render")]
    public class HistogramRenderNode  : FixedShaderNode
    {
        public override string name => "Histogram Render";

        public override string ShaderName => "Hidden/Genesis/HistogramRender";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => 325;

        public override bool hasPreview => true;
    }
}