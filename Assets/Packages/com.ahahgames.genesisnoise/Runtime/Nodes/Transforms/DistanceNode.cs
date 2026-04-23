using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Substance’s Distance node supports:
Euclidean distance
Adjustable max distance
Inversion
Works on grayscale masks
Produces smooth falloff fields
")]

    [System.Serializable, NodeMenuItem("Transform/Distance")]
    public class DistanceNode : FixedNoiseNode
    {
        public override string name => "Distance";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/DistanceTransform";
    }
}