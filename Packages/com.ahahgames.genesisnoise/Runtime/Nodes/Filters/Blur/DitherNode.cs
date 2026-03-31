using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Dithering with an algorithm selection:
Equidistant Sampling
2x2 Ordered dithering offsets
2 step random dithering offsets
Random offset per pixel
")]

    [System.Serializable, NodeMenuItem("Filters/Blur/Dithering")]
    public class DitherNode : FixedNoiseNode
    {
        public override string name => "Dithering";
        public override string NodeGroup => "Blur";
        public override string ShaderName => "Hidden/Genesis/Dither";
    }
}