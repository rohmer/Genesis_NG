using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 - Slanted patterns
- Perspective‑like shears
- Stylized distortions
- Pre‑warping shapes before rotation or polar transforms
- Creating italicized or slanted procedural elements
A proper Skew node lets you shear UVs along X or Y, with:
")]

    [System.Serializable, NodeMenuItem("Transform/Skew")]
    public class SkewNode : FixedNoiseNode
    {
        public override string name => "Skew";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/Skew";
    }
}