using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
    Simulates the grain of wood. The pattern is tileable.
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Wood Grain")]
    public class WoodGrainNode : FixedNoiseNode
    {
        public override string name => "Wood Grain";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/WoodGrain";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}