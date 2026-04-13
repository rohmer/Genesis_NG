using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a finer dirt pattern for subtle grime, dust, and high-frequency surface breakup.
")]

[System.Serializable, NodeMenuItem("Generators/Pattern/Dirt Fine")]
    public class DirtFineNode : FixedNoiseNode
    {
        public override string name => "Dirt Fine";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/GrungeDirtFine";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}
