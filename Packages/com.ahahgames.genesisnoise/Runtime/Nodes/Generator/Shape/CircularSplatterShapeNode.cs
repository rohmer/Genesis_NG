using GraphProcessor;

using System.Collections.Generic;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
This node scatters shape instances around a circle, with full control over:
- Radius
- Angular distribution
- Random rotation
- Random scale
- Radial jitter
- Angular jitter
- Density
- Blend softness
It’s perfect for mandala‑like patterns, stylized ornaments, radial grunge, circular debris, procedural flowers, gears, and anything that needs a radial distribution of shapes

")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Circular Splatter Shape")]
    public class CircularSplatterShapeNode : FixedShaderNode
    {
        public override string name => "Circular Splatter Shape";

        public override string ShaderName => "Hidden/Genesis/ShapeSplatterCircular";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Tile", "_Offset", "_Rotation" };
        public override string NodeGroup => "Shape";
    }
}