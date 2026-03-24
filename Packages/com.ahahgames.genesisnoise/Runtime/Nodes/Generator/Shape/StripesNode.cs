using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a striping pattern
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Stripes")]
    public class StripesNode : FixedShaderNode
    {
        public override string name => "Stripes";

        public override string ShaderName => "Hidden/Genesis/Stripes";

        public override bool DisplayMaterialInspector => true;

    }
}