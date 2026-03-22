using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
In Genesis, this is used for:
- Stylized shape masks
- Region‑aware patterning
- Procedural tile shapes
- Shape‑driven gradients
- Region‑based stylization
To replicate this in Genesis CRT, we combine:
- Region ID
- Bounding Box (normalized UV inside region)
- A shape function (circle, diamond, square, etc.)
- Optional per‑region randomization

")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Flood Fill To Shape")]
    public class FloodFillToShapeNode : FixedNoiseNode
    {
        public override string name => "Flood Fill to Color";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/FloodFillToShape";
    }
}