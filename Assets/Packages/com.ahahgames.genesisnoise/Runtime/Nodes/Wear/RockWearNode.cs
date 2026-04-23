using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Rock Weathering is one of the most visually rewarding material effects you can add.  Rock ages through a combination of:
- Mechanical erosion (wind, water, abrasion)
- Chemical weathering (dissolution, oxidation)
- Cavity darkening
- Edge chipping
- Sediment/dust accumulation
- Micro‑cracks
- Lichen/moss precursors
- Directional wear

")]

    [System.Serializable, NodeMenuItem("Wear/Rock")]
    public class RockWearNode : FixedNoiseNode
    {
        public override string name => "Rock";
        public override string NodeGroup => "Wear";
        public override string ShaderName => "Hidden/Genesis/RockWeathering";
    }
}