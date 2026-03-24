using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The Worley node generates a hybrid procedural noise by combining:
- 2D Worley (cellular) FBM
- 3D Perlin noise
- A multiplicative fusion step
This produces a unique pattern that blends:
- Cellular structures
- Organic turbulence
- Soft fractal breakup
- Mineral‑like textures
It is ideal for:
- Stone and rock materials
- Organic surfaces
- Terrain breakup
- Stylized shading
- Mask generation
- Cloudy or smoky patterns
The node outputs a single scalar noise value with amplitude and contrast shaping.

")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Whorley")]
    public class WhorleyNode : FixedNoiseNode
    {
        public override string name => "Whorley";

        public override string ShaderName => "Hidden/Genesis/Worley";
        public override string NodeGroup => "Noise";
    }
}