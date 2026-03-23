using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Creates a unique multilayer noise image
")]

    [System.Serializable, NodeMenuItem("Generators/Other/Generative Deco")]
    public class GenerativeDecoNode : FixedNoiseNode
    {
        public override string name => "Generative Deco";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/GenerativeDeco";

    }
}