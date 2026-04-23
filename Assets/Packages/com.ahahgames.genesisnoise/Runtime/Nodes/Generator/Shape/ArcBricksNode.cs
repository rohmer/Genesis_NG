using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates concentric arcs, bricks along arcs, per-arc and per-brick randomization, non-square compensation, and a height mask suitable for feeding into your existing Height→Normal, Curvature, etc.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Arc Bricks")]
    public class ArcBricksNode : FixedNoiseNode
    {
        public override string name => "Arc Bricks";
        public override string ShaderName => "Hidden/Genesis/ArcPavement";
        public override string NodeGroup => "Shape";
    }
}