using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

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