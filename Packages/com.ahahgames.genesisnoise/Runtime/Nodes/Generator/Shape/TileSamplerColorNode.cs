using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Tile Sampler Color is the crown jewel of the tile family, which combines:
- Multi‑shape selection
- Multi‑palette color sampling
- Per‑tile random transforms
- Per‑tile color jitter
- Opacity + blend modes
- Deterministic randomness
- CRT‑safe, sampler‑free except for shapes + palettes

")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Tile Sampler Color")]
    public class TileSamplerColorNode : FixedShaderNode
    {
        public override string name => "Tile Sampler Color";

        public override string ShaderName => "Hidden/Genesis/TileSamplerColor";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}