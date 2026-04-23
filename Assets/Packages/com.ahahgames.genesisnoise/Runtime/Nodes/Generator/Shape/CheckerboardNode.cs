using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Checkerboard Noise generator.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Checkboard")]
    public class CheckerboardNode : FixedNoiseNode
    {
        public override string name => "Checkerboard Noise";
        public override string ShaderName => "Hidden/Genesis/Checkerboard";
        public override string NodeGroup => "Shape";
    }
}