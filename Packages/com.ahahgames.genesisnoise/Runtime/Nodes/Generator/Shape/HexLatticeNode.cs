using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a hexagonal lattice pattern
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Hex Lattice")]
    public class HexLatticeNode : FixedShaderNode
    {
        public override string name => "Hex Lattice";

        public override string ShaderName => "Hidden/Genesis/HexLattice";

        public override bool DisplayMaterialInspector => true;

    }
}