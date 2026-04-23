using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 ✔ Reflect UVs across X and/or Y
✔ Optionally mirror around a custom center
✔ Wrap or clamp
✔ Deterministic, no derivatives
✔ Works for 2D / 3D / Cube textures
This is perfect for:
- Symmetry
- Pattern doubling
- Kaleidoscope bases
- Seam removal
- Procedural shape construction
")]

    [System.Serializable, NodeMenuItem("Transform/Mirror")]
    public class MirrorNode : FixedNoiseNode
    {
        public override string name => "Mirror";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/Mirror";
    }
}