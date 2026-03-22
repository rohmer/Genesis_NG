using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a brick wall pattern
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Bricks")]
    public class BricksNode : FixedShaderNode
    {
        public override string name => "Bricks";

        public override string ShaderName => "Hidden/Genesis/Bricks";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}