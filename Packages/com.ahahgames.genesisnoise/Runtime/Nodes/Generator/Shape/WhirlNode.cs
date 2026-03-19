using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a Whirl pattern
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Whirl")]
    public class WhirlNode : FixedShaderNode
    {
        public override string name => "Whirl";

        public override string ShaderName => "Hidden/Genesis/Whirl";

        public override bool DisplayMaterialInspector => true;

    }
}