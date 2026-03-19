using AhahGames.GenesisNoise;
using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System.Collections.Generic;
namespace Genesis
{
    [Documentation(@"
Generates a line pattern. In 3D this node generate cylinders using a signed distance field function.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Cylinder")]
    public class CylinderNode : FixedShaderNode
    {
        public override string name => "Cylinder";

        public override string ShaderName => "Hidden/Genesis/Cylinder";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Tile", "_Offset", "_Rotation" };
    }
}