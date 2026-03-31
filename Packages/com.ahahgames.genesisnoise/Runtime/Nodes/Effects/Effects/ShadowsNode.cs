using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Creates ray‑traced shadows from a height map, with light position, samples, max length, attenuation, opacity, and height scale.
")]

    [System.Serializable, NodeMenuItem("Effects/Shadows")]
    public class ShadowsNode : FixedNoiseNode
    {
        public override string name => "Shadows";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/RTShadows";
    }
}