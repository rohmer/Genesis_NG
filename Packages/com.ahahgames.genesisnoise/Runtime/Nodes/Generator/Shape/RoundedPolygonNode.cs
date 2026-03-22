using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a n-sided polygon with optional rounding
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Rounded Polygon")]
    public class RoundedPolygon : FixedShaderNode
    {
        public override string name => "Rounded Polygon";

        public override string ShaderName => "Hidden/Genesis/RoundedPolygon";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}