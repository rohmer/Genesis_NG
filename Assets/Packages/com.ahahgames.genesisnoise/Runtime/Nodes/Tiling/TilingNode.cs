using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Tile a texture, both straight tiling or stochastic
")]

    [System.Serializable, NodeMenuItem("Tiling/Tile Random")]
    public class TilingNode : FixedShaderNode
    {
        public override string name => "Tiling";

        public override string NodeGroup => "Tiling";
        public override string ShaderName => "Hidden/Genesis/TileRandom";

        public override bool DisplayMaterialInspector => true;
    } 
}
