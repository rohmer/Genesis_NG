using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
• 	A directional linear gradient
• 	With three controllable positions
• 	And three independent values (or colors, but here we stay grayscale for height‑map purity)
• 	Fully rotatable, offsettable, contrast‑shaped
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Directional Gradient")]
    public class DirectionalGradientNode : FixedNoiseNode
    {
        public override string name => "Directional Gradient";
        public override string ShaderName => "Hidden/Genesis/GradientLinear3";
        public override string NodeGroup => "Pattern";
    }
}