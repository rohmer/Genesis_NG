using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Honeycomb Noise")]
    public class HoneycombNoise : FixedNoiseNode
    {
        public override string ShaderName => "Hidden/Genesis/Honeycomb";

        public override string name => "Honeycomb Noise";
        public override string NodeGroup => "Noise";        
    }
}