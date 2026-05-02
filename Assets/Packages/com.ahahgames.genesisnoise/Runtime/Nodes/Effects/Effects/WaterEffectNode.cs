using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Applies the existing water ripple distortion shader as a surfaced Genesis node.

Use it for:
- Ripples and refractive wobble
- Heat-haze style distortion
- Stylized liquid surface motion
")]
    [System.Serializable, NodeMenuItem("Effects/Water Effect")]
    public class WaterEffectNode : FixedNoiseNode
    {
        public override string name => "Water Effect";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/WaterEffect";
    }
}
