using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Leopard Shape Generator

Creates an organic animal-print pattern with irregular rosettes, broken rings, filler spots, and seeded variation.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Leopard")]
    public class LeopardNode : FixedShaderNode
    {
        public override string name => "Leopard";

        public override string ShaderName => "Hidden/Genesis/Leopard";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
