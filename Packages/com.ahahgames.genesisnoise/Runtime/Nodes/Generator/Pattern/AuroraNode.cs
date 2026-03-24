using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
    Simulates an Aurora
")]

    [System.Serializable, NodeMenuItem("Generators/Other/Aurora")]
    public class AuroraNode : FixedNoiseNode
    {
        public override string name => "Aurora";
        public override string NodeGroup => "Other";
        public override string ShaderName => "Hidden/Genesis/Aurora";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}