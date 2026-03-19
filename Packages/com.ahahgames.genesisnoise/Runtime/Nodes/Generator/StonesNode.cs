using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Generation of a stones or pebbles like texture depending on the scale
")]

    [System.Serializable, NodeMenuItem("Generators/Other/Stones")]
    public class StonesNode : FixedNoiseNode
    {
        public override string name => "Stones";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/Stones";
    }
}