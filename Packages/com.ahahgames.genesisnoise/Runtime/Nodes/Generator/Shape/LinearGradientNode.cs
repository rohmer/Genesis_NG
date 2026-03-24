using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- A clean 0→1 linear gradient
- Fully rotatable via _Angle
- Adjustable softness, contrast, offset, tiling
- Perfect for:
- Height ramps
- Directional blending
- Lighting masks
- Shape construction
- Feeding into Slope Blur, Histogram Scan, Curvature, etc.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Linear Gradient")]
    public class LinearGradientNode : FixedNoiseNode
    {
        public override string name => "Linear Gradient";
        public override string ShaderName => "Hidden/Genesis/GradientLinear1";
        public override string NodeGroup => "Shape";
    }
}