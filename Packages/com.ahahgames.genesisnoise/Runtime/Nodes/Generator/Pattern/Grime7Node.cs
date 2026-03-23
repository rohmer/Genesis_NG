using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Other/Grime 7")]
    public class Grime7Node : FixedNoiseNode
    {
        public override string name => "Grime 7";
        public override string NodeGroup => "Generators";
        public override string ShaderName => "Hidden/Genesis/Grunge007";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}