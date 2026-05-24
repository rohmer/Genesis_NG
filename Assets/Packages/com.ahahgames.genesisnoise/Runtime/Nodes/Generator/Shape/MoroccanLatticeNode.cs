using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Moroccan Lattice Shape Generator

Creates a repeating ogee lattice pattern with arched rails, rounded intersections, and optional inner ornament.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Moroccan Lattice")]
    public class MoroccanLatticeNode : FixedShaderNode
    {
        public override string name => "Moroccan Lattice";

        public override string ShaderName => "Hidden/Genesis/MoroccanLattice";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
