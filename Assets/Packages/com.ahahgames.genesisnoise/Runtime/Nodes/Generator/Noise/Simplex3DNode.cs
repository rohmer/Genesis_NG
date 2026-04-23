using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The Simplex3D node generates 3D simplex noise or 3D simplex FBM depending on the selected mode.
It is a high‑performance, deterministic implementation of IQ‑style simplex noise, suitable for:
- Volumetric textures
- 3D procedural materials
- Clouds, fog, smoke
- Organic breakup
- Distortion fields
- Terrain and heightmap detail
- Animated noise (via Offset)
The node outputs a single‑channel scalar noise value, shaped by amplitude and contrast.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Simplex 3D")]
    public class Simplex3DNode : FixedNoiseNode
    {
        public override string name => "Simplex Noise 3D";

        public override string ShaderName => "Hidden/Genesis/Simplex3D";
        public override string NodeGroup => "Noise";
    }
}