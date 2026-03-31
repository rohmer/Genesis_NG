using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Generation of a stones or pebbles like texture depending on the scale
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Stones")]
    public class StonesNode : FixedNoiseNode
    {
        public override string name => "Stones";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Stones";
    }
}