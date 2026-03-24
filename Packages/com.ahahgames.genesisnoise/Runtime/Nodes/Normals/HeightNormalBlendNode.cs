using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Height Normal Blender is one of those deceptively simple but absolutely essential utility nodes. It blends:
- A base normal map
- A detail normal map
- A height map that modulates how strongly the detail normal contributes
It’s basically a height‑aware normal blend, not just a linear lerp.

")]

    [System.Serializable, NodeMenuItem("Normal/Height Normal Blend")]
    public class HeightNormalBlendNode : FixedNoiseNode
    {
        public override string name => "Height Normal Blend";
        public override string NodeGroup => "Normal";
        public override string ShaderName => "Hidden/Genesis/HeightNormalBlender";
    }
}