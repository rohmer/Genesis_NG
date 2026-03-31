using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Blur the input texture using a Box Blur filter in the specified direction.
")]

    [System.Serializable, NodeMenuItem("Filters/Blur/Directional Box Blur")]
    public class DirectionalBlurNode : FixedShaderNode
    {
        public override string name => "Directional Box Blur";
        public override string NodeGroup => "Blur";
        public override string ShaderName => "Hidden/Genesis/DirectionalBlur";

        public override bool DisplayMaterialInspector => true;
    }
}