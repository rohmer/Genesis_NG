using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Return the R, G, B or A channel from an input
")]

    [System.Serializable, NodeMenuItem("Operations/Channel Split")]
    public class ChannelSplitNode : FixedShaderNode
    {
        public override string name => "Combine";
        public override string NodeGroup => "Operations";
        public override string ShaderName => "Hidden/Genesis/Split";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_CombineModeR", "_CombineModeG", "_CombineModeB", "_CombineModeA" };
    }
}