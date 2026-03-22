using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates random torus(es)
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Torus")]
    public class TorusNode : FixedShaderNode
    {
        public override string name => "Rings";

        public override string ShaderName => "Hidden/Genesis/Torus";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Scale", "_Offset" };
        public override string NodeGroup => "Shape";
    }
}