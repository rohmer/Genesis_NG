using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The Simplex2D node generates 2D simplex noise using a clean, deterministic implementation of Inigo Quilez’s classic simplex algorithm.
It is lightweight, fast, and ideal for:
- Organic masks
- Terrain breakup
- Cloud and fog layers
- Stylized materials
- Distortion fields
- Procedural animation
- Noise‑driven effects
This node outputs a single‑channel scalar noise value, with amplitude and contrast shaping for artistic control.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Simplex 2D")]
    public class Simplex2DNode : FixedNoiseNode
    {
        public override string name => "Simplex Noise 2D";

        public override string ShaderName => "Hidden/Genesis/Simplex2D";
        public override string NodeGroup => "Noise";
    }
}