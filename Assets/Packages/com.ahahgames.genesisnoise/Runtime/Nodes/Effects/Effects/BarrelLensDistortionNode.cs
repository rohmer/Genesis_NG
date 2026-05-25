using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Barrel Lens Distortion Effect

Applies radial barrel or pincushion lens distortion to an input texture, with zoom compensation, chromatic fringing, edge fade, and mix controls.
")]

    [System.Serializable, NodeMenuItem("Effects/Barrel Lens Distortion")]
    public class BarrelLensDistortionNode : FixedNoiseNode
    {
        public override string name => "Barrel Lens Distortion";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/BarrelLensDistortion";
    }
}
