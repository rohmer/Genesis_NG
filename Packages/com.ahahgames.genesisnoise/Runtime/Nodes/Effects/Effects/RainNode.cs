using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Effect that simulates rain on the 'Camera'
")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Rain")]
    public class RainNode : FixedNoiseNode
    {
        public override string name => "Rain Effect";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/RainEffect";
    }
}