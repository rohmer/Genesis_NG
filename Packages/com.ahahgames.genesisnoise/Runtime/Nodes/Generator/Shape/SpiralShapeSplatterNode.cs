using GraphProcessor;

using System.Collections.Generic;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
This node scatters shape instances around a spiral path, giving you:
- Spiral arms
- Angular progression
- Radial growth
- Per‑instance rotation, scale, jitter
- Fully deterministic, sampler‑free except for the shape inpu

")] 

    [System.Serializable, NodeMenuItem("Generators/Shapes/Spiral Splatter Shape")]
    public class SpiralSplatterShapeNode : FixedShaderNode
    {
        public override string name => "Spiral Splatter Shape";

        public override string ShaderName => "Hidden/Genesis/ShapeSplatterCircularSpiral";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Tile", "_Offset", "_Rotation" };
        public override string NodeGroup => "Shape";
    }
}