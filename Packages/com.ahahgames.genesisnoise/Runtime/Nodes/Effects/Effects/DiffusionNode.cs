using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
A multi‑iteration blur
• 	With edge‑preserving falloff
• 	Driven by height differences
• 	Producing a soft, organic spreading effect (like watercolor diffusion or clay smearing)
")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Diffusion")]
    public class DiffusionNode : FixedNoiseNode
    {
        public override string name => "Diffusion";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/Diffusion";
    }
}