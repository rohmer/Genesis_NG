using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Harlequin Shape Generator

Creates a repeating diamond pattern with alternating tones, outlines, and optional center accents.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Harlequin")]
    public class HarlequinNode : FixedShaderNode
    {
        public override string name => "Harlequin";

        public override string ShaderName => "Hidden/Genesis/Harlequin";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
