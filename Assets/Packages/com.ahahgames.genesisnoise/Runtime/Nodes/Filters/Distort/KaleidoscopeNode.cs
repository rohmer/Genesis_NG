using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Performs angular kaleidoscope folding
- Applies radial fractal zooming (Mandelbrot‑style smooth zoom)
- Supports 2D / 3D / Cube UV modes
- Has rotation, zoom speed, swirl, center offset, segment count, and fractal warp
- Works with any input texture (or procedural source upstream)
")]

    [System.Serializable, NodeMenuItem("Filters/Distort/Kaleidoscope")]
    public class KaleidoscopeNode : FixedShaderNode
    {
        public override string name => "Kaleidoscope";

        public override string ShaderName => "Hidden/Genesis/Kaleidoscope";
        public override string NodeGroup => "Operations";
        public override bool DisplayMaterialInspector => true;

    }
}