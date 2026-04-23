using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
 Quantize Color Simple is the lightweight posterizer, but Quantize Color  is a more advanced, perceptually‑aware quantizer. It doesn’t just round channels — it quantizes in color space, usually HSV or HSL, and gives artists control over:
- Hue steps
- Saturation steps
- Value steps
- Quantization mode (per‑channel, HSV, HSL)
- Dithering
- Preserving luminance
- Preserving saturation

")]

    [System.Serializable, NodeMenuItem("Color/Quantize")]
    public class QuantizeNode : FixedShaderNode
    {
        public override string name => "Quantize";

        public override string ShaderName => "Hidden/Genesis/QuantizeColor";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => 325;

        public override bool hasPreview => true;
    }
}