using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Greek Key Shape Generator

Creates a repeating meander pattern with stepped rectangular paths and optional mirrored tile alternation.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Greek Key")]
    public class GreekKeyNode : FixedShaderNode
    {
        public override string name => "Greek Key";

        public override string ShaderName => "Hidden/Genesis/GreekKey";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
