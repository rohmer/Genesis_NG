using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Modify the image in the HSV color space.
")]

    [System.Serializable, NodeMenuItem("Color/Hue Saturation Value")]
    public class HSVNode : FixedShaderNode
    {
        public override string name => "Hue Saturation Value";

        public override string ShaderName => "Hidden/Genesis/HSV";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Color";

    }
}