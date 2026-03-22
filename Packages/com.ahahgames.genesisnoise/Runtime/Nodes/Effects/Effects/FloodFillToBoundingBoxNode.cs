using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Flood Fill to Bounding Box does three things:
- Finds the min/max UV extents of each region
- Normalizes the pixel’s position inside that bounding box
- Outputs a 0–1 coordinate inside the region’s box
- R = normalized X
- G = normalized Y
- B = region size (optional)
To do this in a single‑pass CRT shader, we use a hash‑based pseudo‑bounding‑box estimator that is stable and deterministic
")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Flood Fill to Bounding Box")]
    public class FloodFillToBoundingBoxNode : FixedNoiseNode
    {
        public override string name => "Flood Fill to Bounding Box";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/FloodFillToBoundingBox";
    }
}