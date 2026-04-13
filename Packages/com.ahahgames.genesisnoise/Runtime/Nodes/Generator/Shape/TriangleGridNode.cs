using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a repeating triangular grid pattern.
")]

[System.Serializable, NodeMenuItem("Generators/Shapes/Triangle Grid")]
    public class TriangleGridNode : FixedShaderNode
    {
        public override string name => "Triangle Grid";

        public override string ShaderName => "Hidden/Genesis/TriangleGrid";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";

    }
}
