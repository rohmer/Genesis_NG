using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Quick Usage Notes
- _InputTex: supply your grayscale image; _Channel selects which channel to read.
- Remap: use _InputMin/_InputMax to clamp and normalize input; _OutputMin/_OutputMax to remap final range.
- Smoothing: _BlurIterations and _BlurRadius control smoothing; keep iterations low for performance.
- Curvature: _Curvature adds local ridge/valley emphasis; use small values (0.1–0.6) for subtle effect.
- Normal output: enable _OutputNormal to pack a normal map into RGB and height into alpha for downstream use.
- Debug modes help inspect intermediate stages.
")]

    [System.Serializable, NodeMenuItem("Operations/Grayscale To Height")]
    public class ToHeightNode : FixedShaderNode
    {
        public override string name => "Grayscale To Height";

        public override string ShaderName => "Hidden/Genesis/GrayscaleToHeight";

        public override bool DisplayMaterialInspector => true;
    }
}