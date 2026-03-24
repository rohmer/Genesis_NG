using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Dedicated fabric‑specific wear model that simulates:
- Fiber fuzzing
- Thread thinning
- Edge fray
- Dirt accumulation
- Wear along weave direction
- Micro‑pilling
- High‑frequency fiber breakup
- Directional abrasion

")]

    [System.Serializable, NodeMenuItem("Wear/Fabric")]
    public class FabricWearNode : FixedNoiseNode
    {
        public override string name => "Fabric";
        public override string NodeGroup => "Wear";
        public override string ShaderName => "Hidden/Genesis/FabricWeathering";
    }
}