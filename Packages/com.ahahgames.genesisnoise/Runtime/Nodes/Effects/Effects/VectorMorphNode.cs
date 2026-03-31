using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 Vector Morph is one of the most elegant shape‑processing nodes in the entire library. It takes a shape mask and a vector field, and it pushes the shape outward or inward according to that vector field — essentially a vector‑guided dilation/erosion.
It’s not a warp.
It’s not a blur.
It’s not a directional transform.
It is a morphological expansion driven by a vector map.
It has:
- ✔ A vector map (RG = XY direction)
- ✔ A shape mask
- ✔ A morph amount
- ✔ A softness
- ✔ A distance‑based falloff
- ✔ Deterministic, CRT‑safe sampling

")]

    [System.Serializable, NodeMenuItem("Effects/Vector Morph")]
    public class VectorMorphNode : FixedNoiseNode
    {
        public override string name => "Vector Morph";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/VectorMorph";
    }
}