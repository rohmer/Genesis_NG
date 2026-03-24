using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Extracts chroma (colorfulness) from RGB
- Supports multiple chroma models
- Optional hue isolation
- Optional saturation weighting
- Optional luminance compensation
- Fully deterministic
- CRT‑safe
- Artist‑friendly
")]

    [System.Serializable, NodeMenuItem("Color/Chrominance Extract")]
    public class ChrominanceExtractNode : FixedShaderNode
    {
        public override string name => "Chrominance Extract";

        public override string ShaderName => "Hidden/Genesis/ChrominanceExtract";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => 325;

        public override bool hasPreview => true;
    }
}