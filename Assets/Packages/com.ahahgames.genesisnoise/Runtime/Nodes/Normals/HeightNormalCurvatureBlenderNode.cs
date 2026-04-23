using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
- Take base normal, detail normal, and height
- Compute curvature from the height map (Sobel → magnitude → shaping)
- Use curvature to boost detail normal intensity in high‑curvature regions
- Still respect the height‑driven blend mask
- Still use proper tangent‑space normal blending
- Fully deterministic, CRT‑safe, no derivatives
This gives you:
- Sharper detail on edges
- Softer detail in flat regions
- Height‑aware detail placement
- A more physically‑plausible blend

")]

    [System.Serializable, NodeMenuItem("Normal/Height Normal Curvature Blend")]
    public class HeightNormalCurvatureBlendNode : FixedNoiseNode
    {
        public override string name => "Height Normal Curvature Blend";
        public override string NodeGroup => "Normal";
        public override string ShaderName => "Hidden/Genesis/CurvatureAwareHeightNormalBlender";
    }
}