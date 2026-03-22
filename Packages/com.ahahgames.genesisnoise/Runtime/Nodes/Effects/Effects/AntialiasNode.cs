using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
single‑pass, luma‑based edge detection, adaptive blending, CRT‑ready.
- Input: source color
- Output: anti‑aliased color
- Works 2D / 3D / Cube via SAMPLE_X
- Tunable edge threshold and subpixel quality
")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Antialias")]
    public class AntialiasNode : FixedNoiseNode
    {
        public override string name => "Antialias";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/FXAA";
    }
}