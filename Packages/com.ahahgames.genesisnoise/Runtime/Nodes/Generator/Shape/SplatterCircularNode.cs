using GraphProcessor;

using System.Collections.Generic;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Scatters circular shapes across the texture for droplets, bubbles, or patterned masks.
")]

[System.Serializable, NodeMenuItem("Generators/Shapes/Splatter Circular")]
    public class SplatterCircularNode: FixedShaderNode
    {
        public override string name => "Splatter Circular";

        public override string ShaderName => "Hidden/Genesis/SplatterCircular";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Tile", "_Offset", "_Rotation" };
        public override string NodeGroup => "Shape";
    }
}
