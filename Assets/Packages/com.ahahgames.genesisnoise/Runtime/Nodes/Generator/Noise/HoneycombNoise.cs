using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The Honeycomb node generates hexagonal and star‑shaped cellular patterns using a custom hash‑driven lattice evaluation.
It is ideal for:
- Stylized honeycomb textures
- Sci‑fi hex grids
- Organic cellular patterns
- Decorative masks
- Pattern breakup
- UI backgrounds
- Animated hex‑based effects
The node supports two variants:
- Hex — classic honeycomb
- Star — star‑shaped hex cells with smoothed interpolation
Both variants are deterministic, tile‑free, and resolution‑independent.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Honeycomb Noise")]
    public class HoneycombNoise : FixedNoiseNode
    {
        public override string ShaderName => "Hidden/Genesis/Honeycomb";

        public override string name => "Honeycomb Noise";
        public override string NodeGroup => "Noise";        
    }
}