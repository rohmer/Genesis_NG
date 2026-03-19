using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Tile a texture, both straight tiling or stochastic
")]

    [System.Serializable, NodeMenuItem("Operations/Tiling")]
    public class TilingNode : FixedShaderNode
    {
        public override string name => "Tiling";

        public override string NodeGroup => "Operations";
        public override string ShaderName => "Hidden/Genesis/Tiling";

        public override bool DisplayMaterialInspector => true;
    }
}