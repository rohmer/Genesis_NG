using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Other/Dirt 1")]
    public class DirtNode : FixedNoiseNode
    {
        public override string name => "Dirt";
        public override string NodeGroup => "Generators";
        public override string ShaderName => "Hidden/Genesis/GrungeDirt";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}