using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Curvature‑Aware Noise Upscale 3 is the smartest member of the upscale family — it doesn’t just preserve edges, it understands surface curvature and adapts the reconstruction accordingly.
Curvature‑aware upscaling gives you:
✔ Edge preservation
✔ Curvature‑driven sharpening
✔ Detail suppression in concave areas
✔ Detail enhancement on convex ridges
✔ Zero ringing, fully CRT‑safe
")]

    [System.Serializable, NodeMenuItem("Transform/Smart Upsampler Curvature Aware")]
    public class SmartUpsamplerCurvatureAwareNode : FixedNoiseNode
    {
        public override string name => "Smart Upsampler Curvature Aware";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/NoiseUpscale3_CurvatureAware";
    }
}