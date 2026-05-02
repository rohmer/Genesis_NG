using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Checkerboard Noise generator.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Checkerboard")]
    public class CheckerboardNode : FixedNoiseNode
    {
        public override string name => "Checkerboard";
        public override string ShaderName => "Hidden/Genesis/Checkerboard";
        public override string NodeGroup => "Shape";
    }
}
