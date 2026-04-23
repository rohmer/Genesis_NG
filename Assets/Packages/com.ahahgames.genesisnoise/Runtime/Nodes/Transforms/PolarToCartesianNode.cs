using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 Polar → Cartesian is the perfect companion to your Cartesian → Polar node. Together they form a complete bidirectional coordinate‑space toolkit — essential for:
- Undoing polar warps
- Reconstructing circular patterns
- Building kaleidoscopes
- Radial → planar mapping
- Procedural shape generation
- Reversing Genesis’s Polar Transform
")]

    [System.Serializable, NodeMenuItem("Transform/Polar to Cartesian")]
    public class PolarToCartesianNode : FixedNoiseNode
    {
        public override string name => "Polar to Cartesian";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/PolarToCartesian";
    }
}