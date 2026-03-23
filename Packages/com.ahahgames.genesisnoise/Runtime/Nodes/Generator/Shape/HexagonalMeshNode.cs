using GraphProcessor;

using System.Collections.Generic;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- A clean hexagonal mesh (regular hex tiling)
- Adjustable scale, rotation, line width, contrast
- Perfect for:
- sci‑fi panels
- stylized surfaces
- architectural patterns
- curvature‑driven effects
- procedural masks
- Deterministic, CRT‑safe, sampler‑free except optional mask
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Hexagonal Mesh")]
    public class HexagonalMeshNode : FixedShaderNode
    {
        public override string name => "Hexagonal Mesh";

        public override string ShaderName => "Hidden/Genesis/Mesh2";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Tile", "_Offset", "_Rotation" };
        public override string NodeGroup => "Shape";
    }
}