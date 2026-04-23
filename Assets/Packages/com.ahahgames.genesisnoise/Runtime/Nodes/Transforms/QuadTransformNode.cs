using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Maps any quadrilateral → any quadrilateral, which means:
✔ Perspective‑correct warping
✔ Skewing, shearing, corner‑pinning
✔ Mapping textures onto arbitrary 4‑point shapes
✔ Undoing perspective distortion
✔ Preparing masks for projection, decals, UI, etc.
To recreate this in Genesis CRT, we need a bilinear quad mapping:
- Given UV (u, v)
- Map it into a quadrilateral defined by four corner points
- Sample the source texture at that warped coordinate
")]

    [System.Serializable, NodeMenuItem("Transform/Quad Transform")]
    public class QuadTransformNode : FixedNoiseNode
    {
        public override string name => "Quad Transform";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/QuadTransform";
    }
}