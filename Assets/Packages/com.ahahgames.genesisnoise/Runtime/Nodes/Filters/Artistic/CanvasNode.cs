using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
- Paper/canvas fiber grain
- Directional weave (warp/weft)
- Micro‑roughness
- Pigment catch (paint settling into fibers)
- Optional color tinting
")]

    [System.Serializable, NodeMenuItem("Filters/Artistic/Canvas")]
    public class CanvasNode : FixedNoiseNode
    {
        public override string name => "Canvas";
        public override string NodeGroup => "Artistic";
        public override string ShaderName => "Hidden/Genesis/CanvasTexture";
    }
}
