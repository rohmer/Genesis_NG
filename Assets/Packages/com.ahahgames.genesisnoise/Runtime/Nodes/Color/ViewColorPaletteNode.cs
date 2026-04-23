using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Displays 2–16 palette colors
- Supports horizontal or vertical layout
- Supports padding
- Supports border thickness + color
- Supports per‑swatch labels (optional grayscale stripes)
")]

    [System.Serializable, NodeMenuItem("Color/View Color Palette")]
    public class ViewColorPaletteNode: FixedShaderNode
    {
        public override string name => "View Color Palette";

        public override string ShaderName => "Hidden/Genesis/ViewColorPalette";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => 325;

        public override bool hasPreview => true;
    }
}