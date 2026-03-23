using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Other/Dirt Fine")]
    public class DirtFineNode : FixedNoiseNode
    {
        public override string name => "Dirt Fine";
        public override string NodeGroup => "Generators";
        public override string ShaderName => "Hidden/Genesis/GrungeDirtFine";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}