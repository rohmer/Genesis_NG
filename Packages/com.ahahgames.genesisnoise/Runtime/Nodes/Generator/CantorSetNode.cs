using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a Cantor set, a fractal that consists of an infinite number of points, but has zero measure. It is created by repeatedly removing the middle third of a line segment, resulting in a pattern that is self-similar and has a fractal dimension of log(2)/log(3).
")]

    [System.Serializable, NodeMenuItem("Generators/Other/Cantor Set")]
    public class CantorSetNode : FixedNoiseNode
    {
        public override string name => "Cantor Set";
        public override string ShaderName => "Hidden/Genesis/CantorSet";
        public override string NodeGroup => "Other";
    }
}