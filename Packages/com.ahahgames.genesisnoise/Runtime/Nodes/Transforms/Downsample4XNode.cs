using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 Downsamples an input texture by 4x.
")]

    [System.Serializable, NodeMenuItem("Transform/Downsample 4X")]
    public class Downsample4XNode : FixedNoiseNode
    {
        public override string name => "Downsample 4X";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/Downsample4X";
    }
}