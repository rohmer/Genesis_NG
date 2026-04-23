using GraphProcessor;

using System.Collections.Generic;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
generates:
- A triangular mesh (equilateral tiling)
- With barycentric distance shading
- Adjustable line width, contrast, scale, and rotation
- Optional mask
- Perfect for height maps, normals, curvature, and stylized patterns
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Mesh")]
    public class Mesh1Node : FixedShaderNode
    {
        public override string name => "Mesh";

        public override string ShaderName => "Hidden/Genesis/Mesh1";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Tile", "_Offset", "_Rotation" };
        public override string NodeGroup => "Shape";
    }
}