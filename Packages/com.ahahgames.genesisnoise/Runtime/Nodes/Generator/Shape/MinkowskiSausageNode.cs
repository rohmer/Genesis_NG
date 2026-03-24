using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- 6‑map Minkowski IFS (classic + rotated + mirrored segments)
- Orbit‑trap coloring (circle, cross, point)
- Distance‑to‑curve field (smooth SDF‑like)
- IFS morphing (identity → Minkowski)
- Time animation
- Palette shaping
- Density accumulation
")]

    [System.Serializable, NodeMenuItem("Generators/Other/Minkowski Sausage")]
    public class MinkowskiSausageNode : FixedNoiseNode
    {
        public override string name => "Minkowski Sausage";
        public override string ShaderName => "Hidden/Genesis/MinkowskiSausagePro";
        public override string NodeGroup => "Other";
    }
}