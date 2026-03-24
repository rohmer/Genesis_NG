using GraphProcessor;

using System.Collections.Generic;
using System.Linq;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The RidgedCellularNoise node generates high‑contrast, ridge‑enhanced cellular noise in 2D, 3D, or Cube space.
It is built on top of Genesis’ CellularNoise system but applies a ridging transform to produce:
- Sharp ridges
- Deep valleys
- High‑frequency cellular breakup
- Stylized organic patterns
- Cracks, veins, and mineral structures
This makes it ideal for:
- Rock and stone materials
- Alien or organic surfaces
- Stylized terrain
- Cracks, veins, and branching patterns
- Mask generation
- Heightmap breakup
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Ridged Cellular Noise")]
    public class RidgedCellularNoise : FixedNoiseNode
    {
        public override string name => "Ridged Cellular Noise";

        public override string ShaderName => "Hidden/Genesis/RidgedCellularNoise";
        public override string NodeGroup => "Noise";
        protected override IEnumerable<string> filteredOutProperties => base.filteredOutProperties.Concat(new string[] { "_DistanceMode", "_CellsModeR", "_CellsModeG", "_CellsModeB", "_CellsModeA" });
    }
}