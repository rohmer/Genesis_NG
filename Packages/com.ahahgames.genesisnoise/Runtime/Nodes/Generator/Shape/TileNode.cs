using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
It supports:
- Tile count (X/Y)
- Offset
- Rotation per tile
- Scale per tile
- Random jitter
- Random rotation
- Random scale
- Seed‑driven deterministic variation
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Tile")]
    public class TileNode : FixedShaderNode
    {
        public override string name => "Tile";

        public override string ShaderName => "Hidden/Genesis/Tile";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}