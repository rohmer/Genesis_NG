using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates scratch marks for worn, damaged, or weathered surface details.
")]

[System.Serializable, NodeMenuItem("Generators/Pattern/Scratches")]
    public class ScratchesNode : FixedNoiseNode
    {
        public override string name => "Scratches";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Scratches";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}
