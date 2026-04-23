using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Essentially the sibling of Shape Drop Shadow, but instead of casting a directional shadow, it creates a soft, radial, emissive halo around a binary shape.
It’s not bloom, not blur, not bevel — it’s a distance‑based glow with:
- Glow radius
- Softness
- Intensity
- Color
- Optional inner glow
- Fully shape‑aware
")]

    [System.Serializable, NodeMenuItem("Effects/Shape Glow")]
    public class ShapeGlowNode : FixedNoiseNode
    {
        public override string name => "Shape Glow";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/ShapeGlow";
    }
}