using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 Symmetry Slice is the designer’s scalpel — the node that lets you carve the texture into angular wedges, mirror them, rotate them, and recombine them into kaleidoscope‑like structures. It’s the backbone of Genesis’s:
- Kaleidoscope
- Radial patterning
- Mandala‑style shapes
- Procedural flowers, gears, spokes
- Symmetry‑driven masks
A proper Symmetry Slice node needs:
✔ Slice count (number of wedges)
✔ Slice angle
✔ Hard or soft slice boundaries
✔ Optional mirroring inside each slice
✔ Pivot control
✔ Wrap/clamp
✔ Deterministic, CRT‑safe
")]

    [System.Serializable, NodeMenuItem("Transform/Symmetry Slice")]
    public class SymmetrySlice : FixedNoiseNode
    {
        public override string name => "Symmetry Slice";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/SymmetrySlice";
    }
}