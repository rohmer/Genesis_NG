using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
computes an approximate distance map from a binary feature mask derived from the source texture. It scans a circular neighborhood up to _MaxRadius texels and returns the minimum Euclidean distance to the nearest feature pixel. Options let you output normalized distance, pixel distance, or a signed distance (inside/outside). 
")]

    [System.Serializable, NodeMenuItem("Filters/Distance Map")]
    public class DistanceMapNode : FixedNoiseNode
    {
        public override string name => "Distance Map";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/DistanceMap";
    }
}