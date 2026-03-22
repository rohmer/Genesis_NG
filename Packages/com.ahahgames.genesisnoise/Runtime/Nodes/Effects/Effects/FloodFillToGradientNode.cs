using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
This node takes the Region ID map and the Bounding Box map and produces a per‑region gradient, exactly like Substance:
- ✔ Gradient runs inside each region, not globally
- ✔ Uses the region’s bounding box to normalize coordinates
- ✔ Supports direction angle, invert, profile, random per‑region rotation
- ✔ Fully deterministic
- ✔ Fully Genesis CRT–compliant (2D / 3D / Cube, SAMPLE_X, GenesisFragment)

")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Flood Fill to Gradient")]
    public class FloodFillToGradientNode : FixedNoiseNode
    {
        public override string name => "Flood Fill to Gradient";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/FloodFillToGradient";
    }
}