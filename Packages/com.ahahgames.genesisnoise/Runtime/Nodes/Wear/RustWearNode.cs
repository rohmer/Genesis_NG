using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Rust Weathering is one of the most iconic, high‑impact material effects in procedural texturing — and it’s a perfect addition to your growing Material Weathering suite. Rust is not just “orange noise”; it forms through a combination of:
- Cavity moisture retention
- Surface oxidation
- Pitting corrosion
- Flaking and chipping
- Directional runoff
- Iron oxide bloom
- Micro‑scale roughness increase
")]

    [System.Serializable, NodeMenuItem("Wear/Rust")]
    public class RustWearNode : FixedNoiseNode
    {
        public override string name => "Rust";
        public override string NodeGroup => "Wear";
        public override string ShaderName => "Hidden/Genesis/RustWeathering";
    }
}