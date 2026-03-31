using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Swirl node is one of those classic 2D deformation operators: a radial rotation field centered on the UV, with a falloff so pixels near the center rotate more than pixels near the edge.
✔ Centered swirl
✔ Angle amount
✔ Radius
✔ Soft falloff
✔ Bidirectional rotation (positive/negative)
✔ Deterministic, CRT‑safe sampling

")]

    [System.Serializable, NodeMenuItem("Effects/Swirl")]
    public class SwirlNode : FixedNoiseNode
    {
        public override string name => "Swirl";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/Swirl";
    }
}