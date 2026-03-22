using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Sample from a shifted UV position, optionally with mirroring, rotation, offset, and wrap/clamp behavior. It’s basically a UV‑offset sampler with a few quality‑of‑life features.
")]

    [System.Serializable, NodeMenuItem("Transform/Clone")]
    public class CloneNode : FixedNoiseNode
    {
        public override string name => "Clone Node";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/Clone";
    }
}