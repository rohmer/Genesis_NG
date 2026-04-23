using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Replace Color Range is the natural evolution of Replace Color — instead of targeting a single color, you target a band of colors defined by:
- A center color
- A hue range
- A saturation range
- A value (luminance) range
- A fuzziness falloff
- A replacement color
- A blend amount
Think of it as Histogram Select + Replace Color, but in HSV space.
This is extremely useful for stylized workflows:
- Replace all warm hues with cool hues
- Replace all greens with a stylized palette
- Replace all dark reds with bright oranges
- Replace all desaturated colors with a new tone
")]

    [System.Serializable, NodeMenuItem("Color/Replace Color Range")]
    public class ReplaceColorRangeNode : FixedShaderNode
    {
        public override string name => "Replace Color Range";

        public override string ShaderName => "Hidden/Genesis/ReplaceColorRange";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => 325;

        public override bool hasPreview => true;
    }
}