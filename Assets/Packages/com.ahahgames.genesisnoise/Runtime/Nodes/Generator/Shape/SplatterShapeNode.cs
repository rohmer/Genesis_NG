using GraphProcessor;

using System.Collections.Generic;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Scatter many shape instances across a grid
- Per‑instance random position, rotation, scale
- Optional jitter, density, falloff, blending
- Deterministic, sampler‑free except for the input shape
- CRT‑safe, single‑pass, no atomics, no loops dependent on texture size
- Perfect for grunge, debris, organic breakup, stylized masks, and pattern generation
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Splatter Shape")]
    public class SplatterShapeNode : FixedShaderNode
    {
        public override string name => "Splatter Shape";

        public override string ShaderName => "Hidden/Genesis/ShapeSplatter";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Tile", "_Offset", "_Rotation" };
        public override string NodeGroup => "Shape";
    }
}