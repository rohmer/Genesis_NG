using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generate a texture from an HDR color.
")]

    [System.Serializable, NodeMenuItem("Color/Uniform Color"), NodeMenuItem("Color/Color Matte")]
    public class ColorMatteNode : FixedShaderNode
    {
        public override string name => "Color Matte";

        public override string ShaderName => "Hidden/Genesis/ColorMatte";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => GenesisNoiseUtility.smallNodeWidth;

        public override bool hasPreview => false;
    }
}