using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Ot’s more advanced than Make Tiled because it performs:
✔ Multi‑directional edge analysis
✔ Seam removal using mirrored borders
✔ Gradient‑domain blending
✔ Optional random offset
✔ Optional patch‑based jitter
✔ Fully seamless output even for photographic sources
- Mirrors the image at borders
- Blends seams using a gradient‑domain feather
- Supports random offset
- Supports patch jitter
- Is deterministic and CRT‑safe

")]

    [System.Serializable, NodeMenuItem("Tiling/Make Tiled Photo")]
    public class MakeTiledPhotoNode : FixedNoiseNode
    {
        public override string name => "Make Tiled Photo";
        public override string NodeGroup => "Tiling";
        public override string ShaderName => "Hidden/Genesis/MakeItTilePhoto";
    }
}