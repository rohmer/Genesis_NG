using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Applies thermal erosion to a heightmap by transferring material from steep cells to lower neighboring cells.

Use the talus threshold to control which slopes are considered unstable. The strength and transfer rate control how much material moves per pass, while the output mode can show the eroded height, removed material, deposited material, or local slope.
")]
    [System.Serializable, NodeMenuItem("Operations/Thermal Erosion")]
    public class ThermalErosionNode : FixedShaderNode
    {
        public override string name => "Thermal Erosion";

        public override string ShaderName => "Hidden/Genesis/ThermalErosion";
        public override string NodeGroup => "Operations";
        public override bool DisplayMaterialInspector => true;
    }
}
