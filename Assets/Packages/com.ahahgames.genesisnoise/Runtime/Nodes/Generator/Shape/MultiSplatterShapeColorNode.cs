using GraphProcessor;

using System.Collections.Generic;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
This node supports:
✔ Multiple shapes
- Each instance randomly picks from N shapes
- Independent UV transforms per shape
- Independent rotation/scale jitter per shape
✔ Multiple palettes
- Each instance randomly picks from N palettes
- Each palette can be a strip or a full 2D color map
- Per‑palette hue/sat/value jitter
✔ Full per‑instance randomness
- Position
- Rotation
- Scale
- Color
- Opacity
- Blend mode
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Multi Splatter Shape Color")]
    public class MultiSplatterShapeColor : FixedShaderNode
    {
        public override string name => "Multi Splatter Shape Color";

        public override string ShaderName => "Hidden/Genesis/SplatterColorMultiPaletteMultiShape";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Tile", "_Offset", "_Rotation" };
        public override string NodeGroup => "Shape";
    }
}