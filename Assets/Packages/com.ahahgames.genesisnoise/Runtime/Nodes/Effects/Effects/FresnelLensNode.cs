using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Fresnel Lens Effect

Applies concentric Fresnel lens grooves to an input texture, adding radial refraction, chromatic splitting, focus falloff, and ring highlights.
")]

    [System.Serializable, NodeMenuItem("Effects/Fresnel Lens")]
    public class FresnelLensNode : FixedNoiseNode
    {
        public override string name => "Fresnel Lens";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/FresnelLens";
    }
}
