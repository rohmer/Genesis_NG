using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Dots generator.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Dots")]
    public class DotsGeneratorNode : FixedNoiseNode
    {
        public override string name => "Dots Generator";
        public override string NodeGroup => "Generators";
        public override string ShaderName => "Hidden/Genesis/DotsShader";

    }
}