using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Vector Warp is one of the cleanest and most useful deformation nodes in the whole library. Unlike Vector Morph (which grows the shape along a vector field), Vector Warp actually warps the UVs using a vector map.
Think of it as:
✔ A UV displacement
✔ Driven by a vector field (RG = XY)
✔ With intensity
✔ With scale
✔ With optional falloff
✔ Fully per‑pixel

")]

    [System.Serializable, NodeMenuItem("Effects/Vector Warp")]
    public class VectorWarpNode : FixedNoiseNode
    {
        public override string name => "VectorWarp";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/VectorWarp";
    }
}