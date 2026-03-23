using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Each tile randomly selects from multiple input shapes, with deterministic per‑tile randomness, rotation/scale jitter, and clean UV transforms.
This is the backbone of:
- procedural patterns
- stylized motifs
- random grids
- multi‑shape tiling
- texture breakup
- ornamentation
- stylized UI patterns

")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Tile Random")]
    public class TileRandomNode : FixedShaderNode
    {
        public override string name => "Tile Random";

        public override string ShaderName => "Hidden/Genesis/TileRandom";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}