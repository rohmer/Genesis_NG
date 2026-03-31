using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Soft, cinematic bloom
- Thresholded bright-pass
- Multi-radius Gaussian glow
- Chromatic fringing
- Lens dirt scattering
- Physically-inspired bloom rolloff
")]

    [System.Serializable, NodeMenuItem("Operations/Lens Bloom")]
    public class LensBloomNode : FixedShaderNode
    {
        public override string name => "Lens Bloom";

        public override string ShaderName => "Hidden/Genesis/LensBloom";
        public override string NodeGroup => "Operations";
        public override bool DisplayMaterialInspector => true;

    }
}