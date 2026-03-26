using GraphProcessor;

using System.Collections.Generic;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Splatter Shape Circular")]
    public class SplatterShapeCircularNode : FixedShaderNode
    {
        public override string name => "Splatter Shape Circular";

        public override string ShaderName => "Hidden/Genesis/SplatterCircular";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Tile", "_Offset", "_Rotation" };
        public override string NodeGroup => "Shape";
    }
}