using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
A frosted glass style effect
")]

    [System.Serializable, NodeMenuItem("Effects/Blur/Frosted Glass")]
    public class FrostedGlassNode : FixedNoiseNode
    {
        public override string name => "Frosted Glass";
        public override string NodeGroup => "Blur";
        public override string ShaderName => "Hidden/Genesis/FrostedGlass";
    }
}