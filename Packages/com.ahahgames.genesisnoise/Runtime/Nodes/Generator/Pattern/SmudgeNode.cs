using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Smudges")]
    public class SmudgesNode : FixedNoiseNode
    {
        public override string name => "Smudges";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Smudges";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}