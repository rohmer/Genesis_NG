using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a grid pattern
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Grid")]
    public class GridNode : FixedShaderNode
    {
        public override string name => "Grid";

        public override string ShaderName => "Hidden/Genesis/Grid";

        public override bool DisplayMaterialInspector => true;

    }
}