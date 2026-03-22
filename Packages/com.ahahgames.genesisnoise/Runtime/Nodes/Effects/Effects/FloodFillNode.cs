using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Jump‑Flood region propagation + stable hashing for region IDs
This produces a stable region ID map that you can feed into your other CRT nodes.

")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Flood Fill")]
    public class FloodFillNode : FixedNoiseNode
    {
        public override string name => "Flood Fill";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/FloodFill";
    }
}