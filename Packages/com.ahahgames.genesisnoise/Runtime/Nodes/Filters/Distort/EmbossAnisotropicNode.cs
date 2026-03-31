using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
✔ Emboss direction guided by a direction map
✔ Optional structure‑tensor anisotropy (auto‑flow)
✔ Height‑based embossing
✔ Width, depth, profile shaping
✔ Direction strength blending
")]

    [System.Serializable, NodeMenuItem("Filters/Distort/Emboss Anisotropic")]
    public class EmbossAnistropicNode : FixedNoiseNode
    {
        public override string name => "Emboss Anisotropic";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/EmbossAnisotropic";
    }
}