using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
This is the Genesis Noise node that produces:
Organic smearing
Blobby distortions
Melting effects
Soft turbulence
Height‑based warping

And it’s distinct from Directional Warp or Vector Warp.
")]

    [System.Serializable, NodeMenuItem("Transform/Warp")]
    public class WarpNode : FixedNoiseNode
    {
        public override string name => "Warp";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/Warp";
    }
}