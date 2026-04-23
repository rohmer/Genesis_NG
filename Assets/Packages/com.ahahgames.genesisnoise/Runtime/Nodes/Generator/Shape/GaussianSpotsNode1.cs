using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
    - Soft Gaussian blobs
- Smooth photographic falloff
- Random radii per cell
- Overlapping clusters
- Substance‑style additive blending
- Perfect for roughness masks, grunge, organic breakup

")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Gaussian Spots 1")]
    public class GaussianSpots1 : FixedNoiseNode
    {
        public override string name => "Gaussian Spots 1";
        public override string NodeGroup => "Shapes";
        public override string ShaderName => "Hidden/Genesis/GaussianSpots1";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}