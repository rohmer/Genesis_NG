using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
• 	A 1D Gaussian stretched along an axis
• 	With optional per‑cell random rotation
• 	Perfect for fibers, streaks, directional breakup, anisotropic grunge
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Gaussian Axis")]
    public class GaussianAxisNode : FixedNoiseNode
    {
        public override string name => "Gaussian Axis";
        public override string ShaderName => "Hidden/Genesis/GaussianAxial";
        public override string NodeGroup => "Shape";
    }
}