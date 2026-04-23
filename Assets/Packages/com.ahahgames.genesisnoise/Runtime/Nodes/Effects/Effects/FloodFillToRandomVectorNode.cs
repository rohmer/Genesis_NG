using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
This node is the vector‑based sibling of:
• 	Flood Fill to Random Grayscale
• 	Flood Fill to Color
But instead of grayscale or color, each region gets a stable random 2D vector — perfect for:
• 	Anisotropic effects
• 	Direction‑aware noise
• 	Flow‑aligned stylization
• 	Region‑based vector fields
• 	Procedural fiber/grain direction

")]

    [System.Serializable, NodeMenuItem("Effects/Flood Fill to Random Vector")]
    public class FloodFillToRandomVectorNode : FixedNoiseNode
    {
        public override string name => "Flood Fill to Grayscale";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/FloodFillToRandomVector";
    }
}