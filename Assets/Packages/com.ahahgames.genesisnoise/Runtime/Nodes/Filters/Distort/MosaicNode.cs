using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Pixelates the input into square tiles
Adds per‑tile jitter for organic variation
Adds tile shape warp for a hand‑drawn look
Adds edge darkening for stained‑glass / mosaic grout
Fully procedural and deterministic
")]

    [System.Serializable, NodeMenuItem("Filters/Distort/Mosaic Filter")]
    public class MosaicFilterNode : FixedShaderNode
    {
        public override string name => "Mosaic Filter";

        public override string ShaderName => "Hidden/Genesis/MosaicFilter";
        public override string NodeGroup => "Operations";
        public override bool DisplayMaterialInspector => true;

    }
}