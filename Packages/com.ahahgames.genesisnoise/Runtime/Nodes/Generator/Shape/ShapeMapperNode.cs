using GraphProcessor;

using System.Collections.Generic;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
In Genesis, Shape Map is used to:
- turn circles into capsules
- turn squares into rounded squares
- turn gradients into stepped shapes
- remap silhouettes
- build stylized shapes from simple primitives
- create procedural icons, UI shapes, bevel profiles, etc

")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Shape Map")]
    public class ShapeMapperNode : FixedShaderNode
    {
        public override string name => "Shape Map";

        public override string ShaderName => "Hidden/Genesis/ShapeMapper";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Tile", "_Offset", "_Rotation" };
        public override string NodeGroup => "Shape";
    }
}