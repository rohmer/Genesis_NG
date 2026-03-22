using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Herringbone Shape Generator
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Herringbone")]
    public class HerringboneNode : FixedNoiseNode
    {
        public override string name => "Herringbone";
        public override string ShaderName => "Hidden/Genesis/Herringbone";
        public override string NodeGroup => "Shape";
    }
}