using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- A clean radial gradient (center → edge)
- Adjustable radius, softness, contrast, center offset, tiling
- Perfect for:
- Shape generation
- Circular masks
- Height maps
- Lens‑style falloffs
- Organic blending
- Feeding into Slope Blur, Histogram Scan, Curvature, etc.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Circular Gradient")]
    public class GradientCircularNode : FixedNoiseNode
    {
        public override string name => "Circular Gradient";
        public override string ShaderName => "Hidden/Genesis/GradientCircular";
        public override string NodeGroup => "Pattern";
    }
}