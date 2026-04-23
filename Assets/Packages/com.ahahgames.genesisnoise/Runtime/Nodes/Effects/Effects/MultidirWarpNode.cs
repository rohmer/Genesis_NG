using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
- Samples the source multiple times along several directions
- Each direction is modulated by a noise map
- The offsets are blended together
- Produces a soft, organic, multi‑axis distortion
- Unlike Directional Warp, it’s not linear — it’s multi‑vector
So the Genesis CRT version needs:
- ✔ Multiple warp directions
- ✔ Per‑direction noise sampling
- ✔ Strength control
- ✔ Blend mode (average)
- ✔ Works for 2D / 3D / Cube
- ✔ Deterministic, sampler‑free, CRT‑ready
")]

    [System.Serializable, NodeMenuItem("Effects/Multi-Direction Warp")]
    public class MultidirWarpNode : FixedNoiseNode
    {
        public override string name => "Multi-Direction Warp";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/MultiDirectionalWarp";
    }
}