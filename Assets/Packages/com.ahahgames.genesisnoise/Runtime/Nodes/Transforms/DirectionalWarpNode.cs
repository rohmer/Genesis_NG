using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Directional Warp = input warped along a direction, with intensity modulated by a grayscale map.

✔ Warp direction (angle)
✔ Warp intensity
✔ Warp scale
✔ Warp noise / pattern input
✔ UV‑safe warping (no stretching artifacts)
✔ Deterministic, sampler‑free warp field
")]

    [System.Serializable, NodeMenuItem("Transform/Directional Warp")]
    public class DirectionalWarpNode : FixedNoiseNode
    {
        public override string name => "Directional Warp";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/DirectionalWarp";
    }
}