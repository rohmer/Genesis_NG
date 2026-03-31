using AhahGames.GenesisNoise;

using GraphProcessor;

[Documentation(@"
A multi‑iteration direction influenced
• 	With edge‑preserving falloff
• 	Driven by height differences
• 	Producing a soft, organic spreading effect (like watercolor diffusion or clay smearing)
")]

[System.Serializable, NodeMenuItem("Effects/Diffusion Anisotropic")]
public class DiffusionNode : FixedNoiseNode
{
    public override string name => "Diffusion Anisotropic";
    public override string NodeGroup => "Effects";
    public override string ShaderName => "Hidden/Genesis/DiffusionAnisotropic";
}