using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Operations/Wind Erosion")]
    public class WindErosionNode : FixedShaderNode
    {
        public override string name => "Wind Erosion";

        public override string ShaderName => "Hidden/Genesis/WindErosion";
        public override string NodeGroup => "Operations";
        public override bool DisplayMaterialInspector => true;

    }
}