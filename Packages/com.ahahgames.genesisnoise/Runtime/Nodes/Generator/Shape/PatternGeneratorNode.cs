using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Pattern generator.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Pattern")]
    public class PatternGeneratorNode : FixedNoiseNode
    {
        public override string name => "Pattern Generator";
        public override string NodeGroup => "Generators";
        public override string ShaderName => "Hidden/Genesis/PatternGenerator";

    }
}