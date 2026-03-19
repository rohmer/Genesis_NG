using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
A warp like blur between 2 input textures.
")]

    [System.Serializable, NodeMenuItem("Effects/Blur/Warp Blur")]
    public class WarpBlurNode : FixedNoiseNode
    {
        public override string name => "Radial Blur";
        public override string NodeGroup => "Blur";
        public override string ShaderName => "Hidden/Genesis/WarpBlur";
    }
}