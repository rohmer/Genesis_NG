using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
 Luminance High Pass does this:
- Convert input to luminance
- Blur luminance (usually a small radius)
- Subtract blurred luminance from original luminance
- Normalize and clamp
- Optional contrast shaping
")]

    [System.Serializable, NodeMenuItem("Color/Luminance High Pass")]
    public class LuminanceHighPassNode: FixedShaderNode
    {
        public override string name => "Luminance High Pass";

        public override string ShaderName => "Hidden/Genesis/LuminanceHighPass";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => 325;

        public override bool hasPreview => true;
    }
}