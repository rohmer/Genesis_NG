using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Used for:
- Layered materials
- Height‑aware masking
- Height‑based compositing
- Smart material blending
- Weathering systems
- Terrain layering
")]

    [System.Serializable, NodeMenuItem("Operations/Height Blend")]
    public class HeightBlendNode : FixedShaderNode
    {
        public override string name => "Height Blend";

        public override string ShaderName => "Hidden/Genesis/HeightBlend";
        public override string NodeGroup => "Operations";
        public override bool DisplayMaterialInspector => true;

    }
}