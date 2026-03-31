using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Converts an image to a poliginization of the orginal
")]

    [System.Serializable, NodeMenuItem("Effects/Poliginize")]
    public class PoliginizationNode : FixedNoiseNode
    {
        public override string name => "Poliginization";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/Poliginization";
    }
}