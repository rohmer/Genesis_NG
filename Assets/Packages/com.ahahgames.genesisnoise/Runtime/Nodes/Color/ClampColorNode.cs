using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Clamp each channel independently
- Optional min/max per channel
- Optional global clamp (0–1)
- Fully CRT‑safe
- Deterministic
- Artist‑friendly
")]

    [System.Serializable, NodeMenuItem("Color/Clamp")]
    public class ClampColorNode : FixedShaderNode
    {
        public override string name => "Clamp";

        public override string ShaderName => "Hidden/Genesis/ClampColor";
        public override string NodeGroup => "Color";


        public override bool DisplayMaterialInspector => true;
        public override float nodeWidth => 325;

        public override bool hasPreview => true;
    }
}