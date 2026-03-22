using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
- One unique color per region
- Colors are stable (seeded by region ID)
- Fully deterministic
- Works for any number of regions
- Perfect for debugging segmentation or stylized region masks

")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Flood Fill to Color")]
    public class FloodFillToColorNode : FixedNoiseNode
    {
        public override string name => "Flood Fill to Color";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/FloodFillToColor";
    }
}