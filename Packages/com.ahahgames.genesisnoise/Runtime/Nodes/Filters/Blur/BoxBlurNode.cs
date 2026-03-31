using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Blur the input texture using a box blur.
")]

    [System.Serializable, NodeMenuItem("Filters/Blur/Box Blur")]
    public class BoxBlurNode : FixedShaderNode
    {
        public override string name => "Box Blur";
        public override string NodeGroup => "Blur";
        public override string ShaderName => "Hidden/Genesis/BoxBlur";

        public override bool DisplayMaterialInspector => true;
    }
}