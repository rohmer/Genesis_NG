using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 Downsamples an input texture by 2x.
")]

    [System.Serializable, NodeMenuItem("Transform/Downsample 2X")]
    public class Downsample2XNode : FixedNoiseNode
    {
        public override string name => "Downsample 2X";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/Downsample2x";
    }
}