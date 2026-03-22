using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
It’s a procedural halo generator that creates:
- A soft radial glow around bright areas
- With falloff shaping
- Intensity and radius control
- Thresholding so only bright pixels glow
- Fully grayscale‑friendly

")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Glow")]
    public class GlowNode : FixedNoiseNode
    {
        public override string name => "Glow";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/Glow";
    }
}