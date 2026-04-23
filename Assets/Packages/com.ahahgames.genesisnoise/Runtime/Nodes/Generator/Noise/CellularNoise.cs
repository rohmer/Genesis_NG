using GraphProcessor;

using System.Collections.Generic;
using System.Linq;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The CellularNoise node generates Worley‑style cellular noise in 2D, 3D, or Cube space, with full control over:
- Distance metric
- Cell size
- Octaves (FBM)
- Lacunarity & persistence
- Tiling mode
- Output range
- Multi‑channel evaluation (R, RG, RGB, RGBA)
- Multiple cell modes (distance, smooth distance, cells, valleys)
This node is one of the most flexible and powerful procedural building blocks in the Genesis ecosystem, suitable for:
- Stone, rock, and organic textures
- Voronoi patterns
- Cracks, cells, and biological structures
- Stylized noise
- Masks and breakup patterns
- Terrain and material generation
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