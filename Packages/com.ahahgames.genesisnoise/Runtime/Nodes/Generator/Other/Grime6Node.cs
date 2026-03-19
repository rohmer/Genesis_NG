using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Other/Grime 6")]
    public class Grime6Node : FixedNoiseNode
    {
        public override string name => "Grime 6";
        public override string NodeGroup => "Generators";
        public override string ShaderName => "Hidden/Genesis/Grunge006";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}