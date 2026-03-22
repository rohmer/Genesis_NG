using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 Cartesian → Polar is one of those elegant coordinate‑space transforms that unlocks entire families of procedural effects — radial gradients, spirals, polar warps, circular masks, kaleidoscopes, and more.
")]

    [System.Serializable, NodeMenuItem("Transform/Cartesian To Polar")]
    public class CartesianToPolarNode : FixedNoiseNode
    {
        public override string name => "Cartesian To Polar";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/CartesianToPolar";
    }
}