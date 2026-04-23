using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Selects a target color
- Computes distance in color space (usually HSV or HSL)
- Applies a falloff (threshold + fuzziness)
- Replaces the selected region with a new color
- Optionally blends between original and replaced color
- Supports hue‑only, saturation‑only, or full‑color replacement
")]

    [System.Serializable, NodeMenuItem("Color/Replace Color")]
    public class ReplaceColorNode: FixedShaderNode
    {
        public override string name => "Replace Color";

        public override string ShaderName => "Hidden/Genesis/ReplaceColor";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => 325;

        public override bool hasPreview => true;
    }
}