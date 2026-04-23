using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
- Sharper, more detailed curvature
- Better edge detection
- More stable results on noisy heightmaps
- Convex / concave separation
- Fully compatible with 2D / 3D / Cube CRT sampling
")]

    [System.Serializable, NodeMenuItem("Effects/Curvature Sobel")]
    public class CurvatureSobelNode : FixedNoiseNode
    {
        public override string name => "Curvature Sobel";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/CurvatureSobel";
    }
}