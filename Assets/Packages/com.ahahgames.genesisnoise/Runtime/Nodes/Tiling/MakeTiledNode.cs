using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
It works by:
- Cutting the input into patches
- Offsetting them in a grid
- Blending the seams using feathering
- Optionally randomizing rotation/flip
- Producing a perfectly tileable output
✔ Patch grid (NxN)
✔ Random offsets per patch
✔ Optional rotation/flip
✔ Seam feathering
✔ Deterministic sampling
✔ CRT‑safe, no derivatives

")]

    [System.Serializable, NodeMenuItem("Tiling/Make Tiled")]
    public class MakeTiledNode : FixedNoiseNode
    {
        public override string name => "Make Tiled";
        public override string NodeGroup => "Tiling";
        public override string ShaderName => "Hidden/Genesis/MakeItTilePatch";
    }
}