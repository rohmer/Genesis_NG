using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a sixth grime pattern variant for subtle wear, buildup, and masking detail.
")]

[System.Serializable, NodeMenuItem("Generators/Pattern/Grime 6")]
    public class Grime6Node : FixedNoiseNode
    {
        public override string name => "Grime 6";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Grunge006";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}
