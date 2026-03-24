using GraphProcessor;

using System.Collections.Generic;
using System.Linq;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The VoronoiNoise node generates 2D, 3D, or Cube‑space Voronoi (Worley) noise with an extensive set of controls:
- Multiple distance functions
- Multiple generation methods (Cells, Crystal, Glass, Caustic, Distance)
- Optional smoothness and scaling maps
- Adjustable search quality
- Multi‑octave layering
- Multiple output types (Noise, UV, ID)
This node is extremely flexible and ideal for:
- Stone, cracks, and mineral patterns
- Organic cellular structures
- Caustics and glass‑like effects
- Stylized materials
- Procedural masks
- Animated Voronoi
- Domain‑warped patterns (via scaling/smoothness maps)

")]
    [System.Serializable, NodeMenuItem("Generators/Noise/Voronoi Noise")]
    public class VoronoiNoiseNode : FixedNoiseNode
    {
        public override string name => "Voronoi Noise";
        public override string NodeGroup => "Noise";
        public override string ShaderName => "Hidden/Genesis/VoronoiNoise";
        protected override IEnumerable<string> filteredOutProperties =>
            base.filteredOutProperties.Concat(new string[] {
                "_UseScaling", "_UseSmoothness", "_TilingMode", "_Octaves", "_ImageType",
                "_ScaleFactor", "_DistanceFunction", "_MinkowskiPower", "_MethodType",
                "_SearchQuality"});        
    }

}
