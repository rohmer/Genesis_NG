using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Supports RGB or RGBA input
- Per‑channel mixing (R from RGB, G from RGB, B from RGB, A from RGBA)
- Optional clamping
- Optional grayscale output
- Fully deterministic
- CRT‑safe
- Artist‑friendly
")]

    [System.Serializable, NodeMenuItem("Color/Channel Mixer")]
    public class ChannelMixerNode : FixedShaderNode
    {
        public override string name => "Channel Mixer";

        public override string ShaderName => "Hidden/Genesis/ChannelMixer";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => 325;

        public override bool hasPreview => true;
    }
}