using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Other/Scratches")]
    public class ScratchesNode : FixedNoiseNode
    {
        public override string name => "Scratches";
        public override string NodeGroup => "Generators";
        public override string ShaderName => "Hidden/Genesis/Scratches";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}