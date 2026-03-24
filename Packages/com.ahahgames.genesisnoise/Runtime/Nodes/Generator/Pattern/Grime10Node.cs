using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Grime 10")]
    public class Grime10Node : FixedNoiseNode
    {
        public override string name => "Grime 10";
        public override string NodeGroup => "Generators";
        public override string ShaderName => "Hidden/Genesis/Grunge010";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}