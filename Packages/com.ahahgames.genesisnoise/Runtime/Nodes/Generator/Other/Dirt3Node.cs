using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Other/Dirt 3")]
    public class Dirt3Node : FixedNoiseNode
    {
        public override string name => "Dirt 3";
        public override string NodeGroup => "Generators";
        public override string ShaderName => "Hidden/Genesis/GrungeDirt3";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}