using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a bacteria like noise pattern
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Bacteria")]
    public class BacteriaNode : FixedNoiseNode
    {
        public override string name => "Bacteria";
        public override string NodeGroup => "Shape";
        public override string ShaderName => "Hidden/Genesis/Bacteria";
    }
}