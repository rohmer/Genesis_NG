using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a circle or elipse
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Ellipse")]
    public class EllipseNode : FixedShaderNode
    {
        public override string name => "Ellipse";

        public override string ShaderName => "Hidden/Genesis/Ellipse";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}