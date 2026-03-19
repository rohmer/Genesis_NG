using GraphProcessor;

using System.Collections.Generic;
using System.Linq;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Worley noise, also called Voronoi noise and cellular noise, is a noise function introduced by Steven Worley in 1996. 
Worley noise is an extension of the Voronoi diagram that outputs a real value at a given coordinate that corresponds to the distance of the nth nearest seed 
(usually n=1) and the seeds are distributed evenly through the region. Worley noise is used to create procedural textures.")]
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
