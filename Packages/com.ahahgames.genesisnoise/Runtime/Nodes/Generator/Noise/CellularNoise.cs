using GraphProcessor;

using System.Collections.Generic;
using System.Linq;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Cellular Noise generator.
This node is useful to generate cloud like textures, organic cellular patterns or more exotic patterns with stars using the Minkowski distance mode.

Note that for Texture 2D, the z coordinate is used as a seed offset.
This allows you to generate multiple noises with the same UV.
Be careful with because if you use a UV with a distorted z value, you'll get a weird looking noise instead of the normal one.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Cellular Noise")]
    public class CellularNoise : FixedNoiseNode
    {
        public override string name => "Cellular Noise";

        public override string ShaderName => "Hidden/Genesis/CellularNoise";
        public override string NodeGroup => "Noise";
        protected override IEnumerable<string> filteredOutProperties => base.filteredOutProperties.Concat(new string[] { "_DistanceMode", "_CellsModeR", "_CellsModeG", "_CellsModeB", "_CellsModeA" });
    }
}