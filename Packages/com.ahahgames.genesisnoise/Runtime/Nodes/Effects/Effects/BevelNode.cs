using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
• 	A height‑to‑normal conversion
• 	Followed by normal integration
• 	Followed by lighting‑style shading (usually lambertian or half‑lambert)
• 	With optional width, smoothness, and profile shaping

")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Bevel")]
    public class BevelNode : FixedNoiseNode
    {
        public override string name => "Bevel";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/Bevel";
    }
}