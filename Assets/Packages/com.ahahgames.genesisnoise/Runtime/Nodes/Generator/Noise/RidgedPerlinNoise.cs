using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The RidgedPerlinNoise node generates high‑contrast, ridge‑enhanced Perlin FBM noise in 2D, 3D, or Cube space.
It transforms classic Perlin FBM into a sharp, mineral‑like, mountainous pattern by applying a ridging function:
\mathrm{ridge}(x)=1-|x|
This produces:
- Sharp peaks
- Deep valleys
- High‑contrast fractal detail
- Stylized terrain and rock patterns
- Organic breakup masks
It is ideal for:
- Terrain heightmaps
- Stylized rock and stone
- Cracks and erosion masks
- Organic surface breakup
- Procedural materials
- Distortion field
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Ridged Perlin Noise")]
    public class RidgedPerlinNoise : FixedNoiseNode
    {
        public override string name => "Ridged Perlin Noise";

        public override string NodeGroup => "Noise";
        public override string ShaderName => "Hidden/Genesis/RidgedPerlinNoise";
    }
}