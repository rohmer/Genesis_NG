using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
• 	A height‑to‑normal conversion
• 	Followed by normal integration
• 	Followed by lighting‑style shading (usually lambertian or half‑lambert)
• 	With optional width, smoothness, and profile shaping
• 	Softer slopes
• 	No harsh transitions
")]

    [System.Serializable, NodeMenuItem("Effects/Bevel Smooth")]
    public class BevelSmoothNode : FixedNoiseNode
    {
        public override string name => "Bevel Smooth";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/BevelSmooth";
    }
}