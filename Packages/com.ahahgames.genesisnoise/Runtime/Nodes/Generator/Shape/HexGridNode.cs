using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a hexagonal grid pattern
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Hex Grid")]
    public class HexGridNode : FixedShaderNode
    {
        public override string name => "Hex Grid";

        public override string ShaderName => "Hidden/Genesis/HexGrid";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}