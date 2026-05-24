using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Basketweave Shape Generator

Creates a block-style woven pattern where groups of horizontal and vertical strands alternate over and under.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Basketweave")]
    public class BasketweaveNode : FixedShaderNode
    {
        public override string name => "Basketweave";

        public override string ShaderName => "Hidden/Genesis/Basketweave";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
