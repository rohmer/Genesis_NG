using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a variety of noise types based on a dropdown
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Multi Noise")]
    public class MultiNoiseNode : FixedNoiseNode
    {
        public override string ShaderName => "Hidden/Genesis/ValueVoronoiSuite2D";
        public override string NodeGroup => "Noise";
        public override string name => "Multi Noise";
    }
}