using GraphProcessor;

using System.Collections.Generic;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Think of it as the shape‑domain sibling of Height Extrude:
- Instead of extruding a heightmap, you extrude a binary or grayscale shape
- It expands the silhouette outward along a direction
- Produces clean, controllable shape inflation
- Perfect for bevels, outlines, directional offsets, stylized silhouettes, and mask growt
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Shape Extrude")]
    public class ShapeExtrudeNode : FixedShaderNode
    {
        public override string name => "Shape Extrude";

        public override string ShaderName => "Hidden/Genesis/ShapeExtrude";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Tile", "_Offset", "_Rotation" };
        public override string NodeGroup => "Shape";
    }
}