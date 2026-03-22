using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
- Takes a source image
- Takes a noise/intensity map
- Takes a direction angle
- Computes a per‑pixel warp offset = direction × noise × strength
- Samples the source at that offset
- Optionally applies softness (Substance’s “Intensity” curve)
It’s basically:
UV' = UV + dir * noise * strength
But with:
- ✔ Direction angle
- ✔ Noise scale
- ✔ Strength
- ✔ Softness shaping
- ✔ Works on grayscale or color
")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Non-Uniform Directional Warp")]
    public class NonUniformDirWarpNode : FixedNoiseNode
    {
        public override string name => "Multi-Direction Warp";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/NonUniformDirectionalWarp";
    }
}