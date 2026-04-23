using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
It’s essentially a range remapper that:
- Extracts values inside a min/max range
- Softens edges
- Optionally inverts
- Optionally remaps the extracted range to 0–1
It’s simpler than Histogram Scan or Equalize, but it’s incredibly useful for:
- Mask isolation
- Range gating
- Stylized shading
- Procedural selection
- Driving palette or blend nodes
")]

    [System.Serializable, NodeMenuItem("Color/Histogram Range")]
    public class HistogramRangeNode : FixedShaderNode
    {
        public override string name => "Histogram Range";

        public override string ShaderName => "Hidden/Genesis/HistogramRange";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => 325;

        public override bool hasPreview => true;
    }
}