using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Input grayscale → remap to a color palette
- Supports 2–8 colors
- Supports stepped or smooth interpolation
- Supports palette indexing
- Fully deterministic
- CRT‑safe
- Artist‑friendly
")]

    [System.Serializable, NodeMenuItem("Color/Apply Palette")]
    public class ApplyPaletteNode : FixedShaderNode
    {
        public override string name => "Apply Palette";

        public override string ShaderName => "Hidden/Genesis/ApplyPalette";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => 325;

        public override bool hasPreview => true;
    }
}