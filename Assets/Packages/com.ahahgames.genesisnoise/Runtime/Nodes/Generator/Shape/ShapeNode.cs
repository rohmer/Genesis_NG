using GraphProcessor;

using System.Collections.Generic;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
✔ Rectangle
✔ Ellipse
✔ Polygon (N‑gon)
✔ Rounded Rectangle
✔ Softness
✔ Rotation
✔ Scale & Offset
✔ Deterministic, sampler‑free
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Shape")]
    public class ShapeNode : FixedShaderNode
    {
        public override string name => "Shape";

        public override string ShaderName => "Hidden/Genesis/Shape";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Tile", "_Offset", "_Rotation" };
        public override string NodeGroup => "Shape";
    }
}