using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Combine up to 4 textures into one, allowing you to choose which channel to write in the output texture.

Note that for creating HDRP Mask and Detail maps, there are dedicated nodes.
")]

    [System.Serializable, NodeMenuItem("Operations/Channel Combine")]
    public class ChannelCombineNode : FixedShaderNode
    {
        public override string name => "Combine";
        public override string NodeGroup => "Operations";
        public override string ShaderName => "Hidden/Genesis/Combine";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { "_CombineModeR", "_CombineModeG", "_CombineModeB", "_CombineModeA" };
    }
}