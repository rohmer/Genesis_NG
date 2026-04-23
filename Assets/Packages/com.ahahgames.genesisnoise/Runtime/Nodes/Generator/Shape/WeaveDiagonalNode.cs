using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Where the core weave alternates over/under in a checkerboard, Weave 2 introduces a diagonal shift, giving you that iconic twill slant.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Weave Diagonal")]
    public class WeaveDiagonalNode : FixedShaderNode
    {
        public override string name => "Weave Diagonal";

        public override string ShaderName => "Hidden/Genesis/Weave2";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}