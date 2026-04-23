using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Local histogram equalization (windowed CDF approximation)
- Contrast boost
- Adaptive normalization
- Bias + gain shaping
- Fully deterministic
- CRT‑safe
- No texture sampling beyond the input
")]

    [System.Serializable, NodeMenuItem("Color/Histogram Equalize")]
    public class HistogramEqualizeNode : FixedShaderNode
    {
        public override string name => "Histogram Equalize";

        public override string ShaderName => "Hidden/Genesis/HistogramEqualize";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => 325;

        public override bool hasPreview => true;
    }
}