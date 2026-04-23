using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 Upsamples an input texture
")]

    [System.Serializable, NodeMenuItem("Transform/Upsample")]
    public class UpsampleNode : FixedNoiseNode
    {
        public override string name => "Upsample";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/Upsample";
    }
}