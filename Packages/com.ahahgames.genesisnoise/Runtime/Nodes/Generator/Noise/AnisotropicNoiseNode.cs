using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Anisotropic noise with a controllable direction vector, anisotropy amount, and optional rotation. This noise type produces stretched patterns along the specified direction, ideal for simulating:
- Wind-blown surfaces
- Flowing water
- Motion blur effects
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Anisotropic Noise")]
    public class AnisotropicNoiseNode : FixedNoiseNode
    {
        public override string name => "Anisotropic Noise";

        public override string ShaderName => "Hidden/Genesis/AnisotropicNoise";
        public override string NodeGroup => "Noise";
    }
}