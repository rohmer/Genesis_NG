using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Simulates water-driven erosion to carve channels and soften the input heightmap or mask.
")]

[System.Serializable, NodeMenuItem("Operations/Hydraulic Erosion")]
    public class HydraulicErosionNode : FixedShaderNode
    {
        public override string name => "Hydraulic Erosion";

        public override string ShaderName => "Hidden/Genesis/HydraulicErosion";
        public override string NodeGroup => "Operations";
        public override bool DisplayMaterialInspector => true;

    }
}
