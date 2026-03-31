using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
- Edge detection (Sobel‑style)
- Color quantization (toon shading)
- Posterization
- Optional halftone dots
")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Cartoon")]
    public class CartoonNode : FixedNoiseNode
    {
        public override string name => "Cartoon";
        public override string NodeGroup => "Modifiers";
        public override string ShaderName => "Hidden/Genesis/CartoonFilter";
    }
}