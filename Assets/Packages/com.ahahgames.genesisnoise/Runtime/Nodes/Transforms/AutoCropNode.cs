using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 It analyzes the non‑empty region of an image (usually based on luminance or alpha), finds the tightest bounding box, and then crops + rescales the result back to full UV space.
")]

    [System.Serializable, NodeMenuItem("Transform/Auto Crop")]
    public class AutoCropNode : FixedNoiseNode
    {
        public override string name => "Auto Crop";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/AutoCrop";
    }
}