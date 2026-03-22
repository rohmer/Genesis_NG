using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Shape Drop Shadow — the one that takes a shape mask and produces a soft, directional, distance‑based shadow with:
- Direction
- Distance
- Softness
- Opacity
- Color
- Height‑aware falloff (optional in Substance)
This is not a blur, not a bevel — it’s a ray‑marched shadow cast from a binary shape
")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Shape Drop Shadow")]
    public class ShapeDropShadowNode : FixedNoiseNode
    {
        public override string name => "Shape Drop Shadow";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/ShapeDropShadow";
    }
}