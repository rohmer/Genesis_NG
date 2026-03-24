using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
It doesn’t extract a range or scan a threshold — instead, it shifts the entire histogram left or right, optionally wrapping or clamping, and optionally applying contrast shaping.
It’s basically:
\mathrm{out}=\mathrm{saturate}(h+\mathrm{shift})
with optional:
- Wrap mode
- Clamp mode
- Contrast shaping
- Bias/Gain shaping
")]

    [System.Serializable, NodeMenuItem("Color/Histogram Shift")]
    public class HistogramShiftNode: FixedShaderNode
    {
        public override string name => "Histogram Shift";

        public override string ShaderName => "Hidden/Genesis/HistogramShift";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => 325;

        public override bool hasPreview => true;
    }
}