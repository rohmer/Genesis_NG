using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a denser fibrous pattern variant for cloth, paper, or brushed-surface detail.
")]

[System.Serializable, NodeMenuItem("Generators/Shapes/Fibers 2")]
    public class Fibers2Node : FixedShaderNode
    {
        public override string name => "Fibers 2";

        public override string ShaderName => "Hidden/Genesis/GrungeFibersDual";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
