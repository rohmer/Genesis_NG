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
        public override string name => "BW Spots 2";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/WoodGrainNode";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}