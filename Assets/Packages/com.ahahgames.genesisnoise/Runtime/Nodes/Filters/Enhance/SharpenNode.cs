using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Sharpen the input image using a very simple 3x3 sharpening kernel.
")]

    [System.Serializable, NodeMenuItem("Filters/Enhance/Sharpen")]
    public class SharpenNode : FixedShaderNode
    {
        public override string name => "Sharpen";

        public override string ShaderName => "Hidden/Genesis/Sharpen";

        public override bool DisplayMaterialInspector => true;
    }
}