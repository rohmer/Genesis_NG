using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Other/Stylized Pebbles")]
    public class StylizedPebblesNode : FixedNoiseNode
    {
        public override string name => "Grass";
        public override string NodeGroup => "Generators";
        public override string ShaderName => "Hidden/Genesis/StylizedPebbles";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 500;
    }
}