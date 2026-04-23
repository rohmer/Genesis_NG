using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
- Voronoi‑style cell partitioning
- Random per‑cell color
- Cell jitter / irregularity
- Edge width
- Edge softness
- Seed‑driven randomness
It’s essentially a stylized Voronoi mosaic generator.
Below is a fully Genesis CRT–compliant implementation:
- Deterministic
- Sampler‑agnostic (SAMPLE_X)
- Works for 2D / 3D / Cube
- Produces:
- Cell ID
- Random color per cell
- Edge mask
- Soft edges

")]

    [System.Serializable, NodeMenuItem("Effects/Mosaic")]
    public class MosaicNode : FixedNoiseNode
    {
        public override string name => "Mosaic";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/Mosaic";
    }
}