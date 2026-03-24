using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Quantize Color (Simple) is one of the most useful for stylization, posterization, toon shading, palette reduction, and mask creation. The Substance version does exactly this:
- Take an RGB input
- Convert to luminance or operate per‑channel
- Quantize into N discrete steps
- Optionally remap back to 0–1
- Output the quantized color
The “Simple” version in Substance is literally:
\mathrm{quantized}=\frac{\mathrm{round}(v\cdot N)}{N}
Where N is the number of steps.
")]

    [System.Serializable, NodeMenuItem("Color/Quantize Simple")]
    public class QuantizeSimpleNode : FixedShaderNode
    {
        public override string name => "Quantize Simple";

        public override string ShaderName => "Hidden/Genesis/QuantizeColorSimple";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => 325;

        public override bool hasPreview => true;
    }
}