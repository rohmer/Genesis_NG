using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Zebra Shape Generator

Creates an organic zebra-stripe pattern with wavy bands, branching distortion, fur grain, and seeded variation.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Zebra")]
    public class ZebraNode : FixedShaderNode
    {
        public override string name => "Zebra";

        public override string ShaderName => "Hidden/Genesis/Zebra";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
