using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
FX Map node behavior: it scatters oriented brush/shape stamps across the surface with controls for scale, spacing, rotation, jitter, density, brush shape, and layering, plus debug outputs (raw points, mask, orientation, shaded). It is deterministic, sampler‑free, CRT‑safe, supports non‑square compensation, and includes a tiling‑safe seed option pattern you can adapt.
")]

    [System.Serializable, NodeMenuItem("Tiling/FX Map")]
    public class FXMapNode : FixedNoiseNode
    {
        public override string name => "FX Map";
        public override string NodeGroup => "Tiling";
        public override string ShaderName => "Hidden/Genesis/FXMap";
    }
}