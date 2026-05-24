using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Paisley Shape Generator

Creates a repeating boteh paisley pattern with teardrop motifs, inner curls, seed dots, and ornamental relief.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Paisley")]
    public class PaisleyNode : FixedShaderNode
    {
        public override string name => "Paisley";

        public override string ShaderName => "Hidden/Genesis/Paisley";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
