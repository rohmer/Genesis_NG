using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates two different julia fractals
")]

    [System.Serializable, NodeMenuItem("Generators/Other/Julia")]
    public class JuliaNode : FixedNoiseNode
    {
        public override string name => "Julia";
        public override string ShaderName => "Hidden/Genesis/Julia";
        public override string NodeGroup => "Other";
    }
}