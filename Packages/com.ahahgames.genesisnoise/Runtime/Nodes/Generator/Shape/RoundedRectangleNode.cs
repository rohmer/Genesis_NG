using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a square or rectangle with rounded sides
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Rounded Rectangle")]
    public class RoundedRectangleNode : FixedShaderNode
    {
        public override string name => "Rounded Rectangle";

        public override string ShaderName => "Hidden/Genesis/RoundedRectangle";

        public override bool DisplayMaterialInspector => true;

    }
}