using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Ogee Shape Generator

Creates a repeating ogee pattern with mirrored S-curved frames, inner echo lines, rounded joints, and optional center drops.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Ogee")]
    public class OgeeNode : FixedShaderNode
    {
        public override string name => "Ogee";

        public override string ShaderName => "Hidden/Genesis/Ogee";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
