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
        public override string ShaderName => "Hidden/Genesis/PatternGenerator";
        public override string NodeGroup => "Shape";
    }
}