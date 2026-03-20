using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Non-Uniform blur where blur radius is determined by the intensity map
")]

    [System.Serializable, NodeMenuItem("Effects/Blur/Non-Uniform Blur")]
    public class SlopeBlurNode : FixedShaderNode
    {
        public override string name => "Non-Uniform Blur";
        public override string NodeGroup => "Blur";
        public override string ShaderName => "Hidden/Genesis/NonUniformBlur";

        public override bool DisplayMaterialInspector => true;
    }
}
