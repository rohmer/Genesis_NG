using GraphProcessor;

using System.Collections.Generic;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
This Splatter Shape Color gives you:
- Per‑instance random color
- Optional color palette sampling (via a color map)
- Blend modes (normal, additive, multiply)
- Random hue/sat/value jitter
- Random brightness
- Random opacity
- Fully deterministic, sampler‑free except for the shape + optional palette

")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Splatter Shape Color")]
    public class SplatterShapeColor : FixedShaderNode
    {
        public override string name => "Splatter Shape Color";

        public override string ShaderName => "Hidden/Genesis/SplatterColor";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Tile", "_Offset", "_Rotation" };
        public override string NodeGroup => "Shape";
    }
}