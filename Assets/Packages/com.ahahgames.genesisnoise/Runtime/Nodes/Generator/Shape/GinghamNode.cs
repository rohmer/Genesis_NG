using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Gingham Shape Generator

Creates a woven checked fabric pattern from overlapping horizontal and vertical bands.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Gingham")]
    public class GinghamNode : FixedShaderNode
    {
        public override string name => "Gingham";

        public override string ShaderName => "Hidden/Genesis/Gingham";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
