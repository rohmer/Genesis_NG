using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Metal ages in ways that are completely different from fabric, leather, or stone. It develops:
- Edge wear / brightening
- Cavity rust
- Oxidation layers
- Pitting and micro‑corrosion
- Directional scratches
- Oil/dirt accumulation
- Heat tinting (optional)
Genesis achieves this through curvature, cavity detection, micro‑noise, and directional abrasion.
")]

    [System.Serializable, NodeMenuItem("Wear/Metal")]
    public class MetalWearNode : FixedNoiseNode
    {
        public override string name => "Metal";
        public override string NodeGroup => "Wear";
        public override string ShaderName => "Hidden/Genesis/MetalWeathering";
    }
}