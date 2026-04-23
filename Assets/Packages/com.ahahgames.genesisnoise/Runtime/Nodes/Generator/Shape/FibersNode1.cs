using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a fibrous pattern useful for fabric, paper, hairline streaks, and brushed surfaces.
")]

[System.Serializable, NodeMenuItem("Generators/Shapes/Fibers")]
    public class Fibers1Node : FixedShaderNode
    {
        public override string name => "Fibers 1";

        public override string ShaderName => "Hidden/Genesis/GrungeFibers";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
