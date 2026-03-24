using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
The PerlinNoise node generates 2D or 3D Perlin FBM noise with full control over:
- Frequency
- Octaves
- Persistence
- Lacunarity
- Output range
- Tiling mode
- Multi‑channel evaluation (R, RG, RGB, RGBA)
This node is a foundational building block for procedural materials, masks, terrain, clouds, and stylized effects

")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Perlin Noise")]
    public class PerlinNoise : FixedNoiseNode
    {
        public override string name => "Perlin Noise";
        public override string NodeGroup => "Noise";
        public override string ShaderName => "Hidden/Genesis/PerlinNoise";        
    }
}
