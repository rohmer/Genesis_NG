using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
It’s not Perlin, not Worley, not Clouds — it’s a hybrid pattern that looks like:
- Wet patches
- Water absorption
- Damp stains
- Organic spreading
- Soft cellular breakup
- Slight directional bias
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Moisture Noise")]
    public class MoistureNoise : FixedNoiseNode
    {
        public override string ShaderName => "Hidden/Genesis/MoistureNoise";

        public override string name => "Moisture Noise";
        public override string NodeGroup => "Noise";
    }
}