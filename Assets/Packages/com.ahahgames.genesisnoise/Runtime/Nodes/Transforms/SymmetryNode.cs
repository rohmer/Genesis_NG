using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 Symmetry is one of those foundational procedural tools — the kind of node that quietly powers half of Genesis’s shape, pattern, and kaleidoscope workflows. A proper symmetry node should let you:
✔ Mirror across X, Y, or both
✔ Choose symmetry count (2‑way, 4‑way, 6‑way, etc.)
✔ Choose pivot/center
✔ Wrap or clamp
✔ Deterministic, CRT‑safe
✔ Works for 2D / 3D / Cube textures

")]

    [System.Serializable, NodeMenuItem("Transform/Symmetry")]
    public class SymmetryNode : FixedNoiseNode
    {
        public override string name => "Symmetry";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/Symmetry";
    }
}