using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Fibers")]
    public class Fibers1Node : FixedShaderNode
    {
        public override string name => "Fibers 1";

        public override string ShaderName => "Hidden/Genesis/GrungeFibers";

        public override bool DisplayMaterialInspector => true;

    }
}