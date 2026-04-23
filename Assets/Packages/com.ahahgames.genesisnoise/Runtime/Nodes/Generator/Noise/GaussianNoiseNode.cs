using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Deterministic, sampler‑free Gaussian noise
Adjustable mean & variance
Adjustable scale
Seed
Optional color output
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Gaussian Noise")]
    public class GaussianNoiseNode : FixedNoiseNode
    {
        public override string ShaderName => "Hidden/Genesis/GaussianNoise";

        public override string name => "Gaussian Noise";
        public override string NodeGroup => "Noise";
    }
}