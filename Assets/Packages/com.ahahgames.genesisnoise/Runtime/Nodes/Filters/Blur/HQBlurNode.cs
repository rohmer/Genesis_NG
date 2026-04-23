using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
High quality blur
Downsample → blur → upsample → blend

Produces large‑radius, smooth, artifact‑free blur

Matches Substance’s Blur HQ behavior

Works for grayscale and color
")]

    [System.Serializable, NodeMenuItem("Filters/Blur/HQ Blur")]
    public class HQBlurNode : FixedShaderNode
    {
        public override string name => "HQ Blur";
        public override string NodeGroup => "Blur";
        public override string ShaderName => "Hidden/Genesis/BlurHQ";

        public override bool DisplayMaterialInspector => true;
    }
}