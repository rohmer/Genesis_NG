using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Radial Blur
")]

    [System.Serializable, NodeMenuItem("Effects/Blur/Radial Blur")]
    public class RadialBlurNode : FixedNoiseNode
    {
        public override string name => "Radial Blur";
        public override string NodeGroup => "Blur";
        public override string ShaderName => "Hidden/Genesis/RadialBlur";
    }
}