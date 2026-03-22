using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
- ✔ True morphological dilation
- ✔ Radius‑based expansion
- ✔ Soft falloff (“Smooth” mode)
- ✔ Iterative growth
- ✔ Optional directional bias (like Extend Shape Directional)
- ✔ Works for 2D / 3D / Cube
")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Extend Shape")]
    public class ExtendShapeNode : FixedNoiseNode
    {
        public override string name => "Extend Shape";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/ExtendShape";
    }
}