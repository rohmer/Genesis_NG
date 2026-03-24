using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"

")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Cobblestone")]
    public class CobblestoneNode : FixedNoiseNode
    {
        public override string name => "Pebbles";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Cobblestone";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 500;
    }
}