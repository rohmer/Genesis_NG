using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The BlueNoise node generates a high‑quality, tile‑free, spatially uniform blue‑noise mask using a Hilbert‑curve R1 quasirandom sequence.
This pattern is ideal for:
- Dithering
- Stochastic sampling
- Procedural scattering
- Pattern breakup
- Anti‑aliasing
- Poisson‑like distributions
Blue noise avoids clustering and low‑frequency artifacts, producing visually pleasing, evenly spaced randomness.

")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Blue Noise")]
    public class BlueNoise : FixedNoiseNode
    {
        public override string name => "Blue Noise";

        public override string ShaderName => "Hidden/Genesis/BlueNoise";
        public override string NodeGroup => "Noise";
    }
}