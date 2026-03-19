using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Mirror the input texture along an axis or a corner.
")]

    [System.Serializable, NodeMenuItem("Operations/Mirror")]
    public class MirrorNode : FixedShaderNode
    {
        public override string name => "Mirror";

        public override string ShaderName => "Hidden/Genesis/Mirror";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Mode", "_CornerType", "_CornerZPosition" };
    }
}