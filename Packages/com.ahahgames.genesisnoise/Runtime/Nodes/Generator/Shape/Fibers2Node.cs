using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Fibers 2")]
    public class Fibers2Node : FixedShaderNode
    {
        public override string name => "Fibers 2";

        public override string ShaderName => "Hidden/Genesis/GrungeFibersDual";

        public override bool DisplayMaterialInspector => true;

    }
}