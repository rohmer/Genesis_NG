using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Applies erosion-style wear to the input to help shape weathered heightmaps and natural surface breakup.
")]

[System.Serializable, NodeMenuItem("Operations/Erosion")]
    public class ErosionNode : FixedShaderNode
    {
        public override string name => "Erosion";

        public override string ShaderName => "Hidden/Genesis/Erosion";
        public override string NodeGroup => "Operations";
        public override bool DisplayMaterialInspector => true;

    }
}
