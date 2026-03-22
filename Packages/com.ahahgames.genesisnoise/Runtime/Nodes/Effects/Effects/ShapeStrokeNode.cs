using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
e deceptively simple nodes that actually does a very specific geometric operation:
✔ It generates an outline around a binary shape
✔ The outline has a thickness
✔ It has softness (feathering)
✔ It supports inner, outer, or both stroke modes
✔ It is distance‑based, not blur‑based
To recreate this in Genesis CRT, we have:
- A distance check around the shape
- A stroke band (inner/outer)
- A soft falloff
- A color + opacity
- Fully deterministic, CRT‑safe sampling

")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Shape Stroke")]
    public class ShapeStrokeNode : FixedNoiseNode
    {
        public override string name => "Shape Glow";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/ShapeStroke";
    }
}