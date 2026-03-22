using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Blue Noise generator.
This node is particularly useful for generating random points that are of a specific density for input into other nodes.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Blue Noise")]
    public class BlueNoise : FixedNoiseNode
    {
        public override string name => "Blue Noise";

        public override string ShaderName => "Hidden/Genesis/BlueNoise";
        public override string NodeGroup => "Noise";
    }
}