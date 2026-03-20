using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Directional blur with the direction given as the slope of a grayscale input
")]

    [System.Serializable, NodeMenuItem("Effects/Blur/Slope Blur")]
    public class NonUniformBlurNode : FixedShaderNode
    {
        public override string name => "Slope Blur";
        public override string NodeGroup => "Blur";
        public override string ShaderName => "Hidden/Genesis/SlopeBlurGrayscale";

        public override bool DisplayMaterialInspector => true;
    }
}
