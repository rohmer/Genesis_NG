using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
- Takes a tangent‑space normal map
- Converts from 0–1 → −1..1
- Flips the X and Y channels (Z stays the same)
- Re‑normalizes
- Outputs back in 0–1 space
")]

    [System.Serializable, NodeMenuItem("Normal/Normal Invert")]
    public class NormalInvertNode : FixedNoiseNode
    {
        public override string name => "Normal Invert";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/NormalInvert";
    }
}