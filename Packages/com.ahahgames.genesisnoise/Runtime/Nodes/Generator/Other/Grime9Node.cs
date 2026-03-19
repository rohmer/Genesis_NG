using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Other/Grime 9")]
    public class Grime9Node : FixedNoiseNode
    {
        public override string name => "Grime 9";
        public override string NodeGroup => "Generators";
        public override string ShaderName => "Hidden/Genesis/Grunge009";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}