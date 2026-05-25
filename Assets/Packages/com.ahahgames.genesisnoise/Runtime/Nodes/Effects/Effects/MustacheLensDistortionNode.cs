using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Mustache Lens Distortion Effect

Applies compound radial lens distortion with barrel pull near the center and pincushion correction toward the edges.
")]

    [System.Serializable, NodeMenuItem("Effects/Mustache Lens Distortion")]
    public class MustacheLensDistortionNode : FixedNoiseNode
    {
        public override string name => "Mustache Lens Distortion";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/MustacheLensDistortion";
    }
}
