using AhahGames.GenesisNoise;
using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System.Collections.Generic;

namespace Genesis
{
    [Documentation(@"
Generate a rectangle pattern. In 3D this node generates cuboid shapes.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Rectangles")]
    public class RectanglesNode : FixedShaderNode
    {
        public override string name => "Rectangles";

        public override string ShaderName => "Hidden/Genesis/Rectangles";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 350;
    }
}