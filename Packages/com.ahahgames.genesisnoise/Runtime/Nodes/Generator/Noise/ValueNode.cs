using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The ValueNoise (2D / 3D / 4D) node generates deterministic, sampler‑free value noise in 2D, 3D, or 4D space.
It uses hash‑based corner values and smooth interpolation to produce:
- Soft gradients
- Organic patterns
- Procedural masks
- Stylized materials
- Distortion fields
- Volumetric noise (3D)
- Animated 4D noise (time as W)
This node is ideal when you need predictable, tile‑free, dimension‑independent noise without the complexity of Perlin or Simplex.

")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Value")]
    public class ValueNode : FixedNoiseNode
    {
        public override string name => "Value";

        public override string ShaderName => "Hidden/Genesis/ValueNoise_2D3D4D";
        public override string NodeGroup => "Noise";
    }
}