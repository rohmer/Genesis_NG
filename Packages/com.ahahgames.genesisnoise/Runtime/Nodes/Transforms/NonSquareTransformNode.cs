using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 ✔ Remap a non‑square texture into square UV space
✔ Stretch or compress X/Y independently
✔ Maintain aspect ratio or override it
✔ Recenter the transformed region
✔ Use it as a pre‑warp for polar, kaleidoscope, shape, or pattern nodes
In Genesis, this node is used constantly for:
- Converting rectangular photos into square procedural space
- Preparing masks for polar transforms
- Fixing aspect‑ratio distortions
- Making procedural shapes uniform
- Pre‑warping noise
")]

    [System.Serializable, NodeMenuItem("Transform/Non-Square Transform")]
    public class NonSquareTransformNode : FixedNoiseNode
    {
        public override string name => "Non-Square Transform";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/NonSquareTransform";
    }
}