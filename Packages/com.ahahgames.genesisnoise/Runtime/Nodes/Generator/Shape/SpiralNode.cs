using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a spiral pattern
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Spiral")]
    public class SpiralNode : FixedShaderNode
    {
        public override string name => "Spiral";

        public override string ShaderName => "Hidden/Genesis/Spiral";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}