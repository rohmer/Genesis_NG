using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
- Each region gets one random grayscale value
- All pixels in that region share the same value
- Randomness is stable (seeded by region ID)
- Works for any number of regions
- Fully deterministic
")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Flood Fill to Grayscale")]
    public class FloodFillToGrayscaleNode : FixedNoiseNode
    {
        public override string name => "Flood Fill to Grayscale";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/FloodFillToRandomGrayscale";
    }
}