using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
A bent normal is essentially:
✔ A normal vector bent away from occlusion
✔ Computed from a height map
✔ Using multi‑directional horizon scanning
✔ Producing a “best visible direction” normal
It’s like a hybrid between:
- Ambient occlusion
- Curvature
- A visibility‑weighted normal
And it’s incredibly useful for:
- Stylized shading
- Edge wear
- Directional AO
- Smart masks
- Height‑aware blending
")]

    [System.Serializable, NodeMenuItem("Normal/Bent Normal")]
    public class BentNormalNode : FixedNoiseNode
    {
        public override string name => "Bent Normal";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/BentNormal";
    }
}