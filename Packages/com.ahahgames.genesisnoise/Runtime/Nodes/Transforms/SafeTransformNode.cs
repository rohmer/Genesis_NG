using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
The node you drop in when you want to transform UVs without ever breaking tiling, aspect ratio, or bounds. It’s essentially a bounded, aspect‑aware, non‑destructive transform wrapper around:
- Translation
- Rotation
- Uniform scaling
- Optional pivot
- Optional safe‑region clamping
The key idea:
No matter what transform you apply, the UVs stay inside 0–1 and never produce invalid sampling.
")]

    [System.Serializable, NodeMenuItem("Transform/Safe Transform")]
    public class SafeTransformNode : FixedNoiseNode
    {
        public override string name => "Safe Transform";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/SafeTransform";
    }
}