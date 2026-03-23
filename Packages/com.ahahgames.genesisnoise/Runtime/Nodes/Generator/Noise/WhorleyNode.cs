using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Whorley Noise
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Whorley")]
    public class WhorleyNode : FixedNoiseNode
    {
        public override string name => "Whorley";

        public override string ShaderName => "Hidden/Genesis/Worley";
        public override string NodeGroup => "Noise";
    }
}