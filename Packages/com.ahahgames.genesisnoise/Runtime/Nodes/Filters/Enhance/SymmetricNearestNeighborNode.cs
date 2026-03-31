using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
 symmetric nearest‑neighbor smoothing filter. For each symmetric pair of samples (left/right and up/down) at each radius step the shader picks the sample that is closer in luminance to the center (nearest neighbor in appearance) and accumulates those chosen samples. This preserves edges and fine detail better than a naive box blur while still removing high‑frequency noise.
")]

    [System.Serializable, NodeMenuItem("Filters/Enhance/Symmetric Nearest Neighbor")]
    public class SymmetricNearestNeighborNode : FixedShaderNode
    {
        public override string name => "Symmetric Nearest Neighbor";

        public override string ShaderName => "Hidden/Genesis/SymmetricNearestNeighbor";

        public override bool DisplayMaterialInspector => true;
    }
}