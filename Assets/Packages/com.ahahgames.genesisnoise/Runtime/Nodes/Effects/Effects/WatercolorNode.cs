using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Scale controls blotch size. Use larger X/Y to stretch blotches.
Layers increases richness and overlap; higher values are slower.
Bleed softens blotch edges and increases watercolor diffusion.
Flow creates directional streaking; combine with nonzero _Scale X/Y differences for directional brush effects.
EdgeDark strengthens wet edges and pigment pooling.
PaperGrain and GrainScale add realistic paper texture and granulation.
")]

    [System.Serializable, NodeMenuItem("Effects/Watercolor")]
    public class WatercolorNode : FixedNoiseNode
    {
        public override string name => "Watercolor";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/Watercolor";
    }
}