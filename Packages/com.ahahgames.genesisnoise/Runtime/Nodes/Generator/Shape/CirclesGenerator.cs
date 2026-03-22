using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generate a Disk, in 3D this node generate a solid spheres.
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Disk"), NodeMenuItem("Generators/Shapes/Sphere")]
    public class CircleNode : FixedShaderNode
    {
        public override string name => "Disk";
        public override string NodeGroup => "Shape";
        public override string ShaderName => "Hidden/Genesis/Circles";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Tile", "_Offset" };
    }
}