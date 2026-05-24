using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Chinoiserie Shape Generator

Creates a stylized scenic ornamental pattern with curved branches, blossoms, clouds, and pagoda-like accents.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Chinoiserie")]
    public class ChinoiserieNode : FixedShaderNode
    {
        public override string name => "Chinoiserie";

        public override string ShaderName => "Hidden/Genesis/Chinoiserie";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}
