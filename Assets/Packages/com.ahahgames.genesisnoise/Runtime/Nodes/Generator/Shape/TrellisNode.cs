using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Trellis Shape Generator

Creates a repeating diagonal lattice pattern with rounded intersections and optional cell ornaments.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Trellis")]
    public class TrellisNode : FixedShaderNode
    {
        public override string name => "Trellis";

        public override string ShaderName => "Hidden/Genesis/Trellis";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
