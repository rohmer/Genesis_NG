using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
- Moisture retention
- Shadowed / occluded areas
- Surface roughness
- Crevices and cavities
- North‑facing slopes
- Ambient humidity
- Random organic clustering
")]

    [System.Serializable, NodeMenuItem("Wear/Moss")]
    public class MossWearNode : FixedNoiseNode
    {
        public override string name => "Moss";
        public override string NodeGroup => "Wear";
        public override string ShaderName => "Hidden/Genesis/MossWeathering";
    }
}