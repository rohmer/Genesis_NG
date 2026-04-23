using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
FXAA-style antialiasing for generated textures.
- Input: source color
- Output: smoothed color with preserved detail
- Works on 2D textures, 3D slices, and cube faces
- Tunable thresholds, span, and subpixel blending
")]

    [System.Serializable, NodeMenuItem("Filters/Enhance/Antialias")]
    public class AntialiasNode : FixedShaderNode
    {
        public override string name => "Antialias";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/FXAA";
        public override bool DisplayMaterialInspector => true;
    }
}
