using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Brocade Shape Generator

Creates an ornamental woven fabric pattern with mirrored medallions, petal motifs, and vine-like diagonal repeats.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Brocade")]
    public class BrocadeNode : FixedShaderNode
    {
        public override string name => "Brocade";

        public override string ShaderName => "Hidden/Genesis/Brocade";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
