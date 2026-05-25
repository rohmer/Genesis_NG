using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Pincushion Lens Distortion Effect

Applies inward radial pincushion lens distortion to an input texture, with zoom compensation, chromatic fringing, edge fade, and mix controls.
")]

    [System.Serializable, NodeMenuItem("Effects/Pincushion Lens Distortion")]
    public class PincushionLensDistortionNode : FixedNoiseNode
    {
        public override string name => "Pincushion Lens Distortion";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/PincushionLensDistortion";
    }
}
