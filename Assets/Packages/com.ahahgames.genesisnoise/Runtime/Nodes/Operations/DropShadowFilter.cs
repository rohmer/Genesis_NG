using GraphProcessor;

using UnityEngine.UI;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Creates a soft, directional shadow behind any grayscale mask
- Adjustable offset, softness, opacity, color
- Optional inner shadow mode
- Fully procedural and CRT‑safe
")]

    [System.Serializable, NodeMenuItem("Operations/Drop Shadow Filter")]
    public class DropShadowFilterNode : FixedShaderNode
    {
        public override string name => "Drop Shadow Filter";

        public override string ShaderName => "Hidden/Genesis/DropShadowFilter";
        public override string NodeGroup => "Operations";
        public override bool DisplayMaterialInspector => true;

    }
}