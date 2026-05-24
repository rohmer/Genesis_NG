using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Damask Shape Generator

Creates a mirrored ornamental fabric pattern with ogee frames, leaf motifs, and repeating scrollwork.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Damask")]
    public class DamaskNode : FixedShaderNode
    {
        public override string name => "Damask";

        public override string ShaderName => "Hidden/Genesis/Damask";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
