using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
- Extract crack lines from an input (usually height or mask)
- Expand or contract the cracks
- Add micro‑erosion around crack edges
- Add cavity darkening
- Add edge brightening
- Add optional dust accumulation
- Output a clean mask or stylized crack map
")]

    [System.Serializable, NodeMenuItem("Wear/Cracks")]
    public class CracksWearNode : FixedNoiseNode
    {
        public override string name => "Cracks";
        public override string NodeGroup => "Wear";
        public override string ShaderName => "Hidden/Genesis/CracksWeathering";
    }
}