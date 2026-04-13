using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a stylized pebble pattern suitable for ground textures, masks, and decorative surfaces.
")]

[System.Serializable, NodeMenuItem("Generators/Pattern/Stylized Pebbles")]
    public class StylizedPebblesNode : FixedNoiseNode
    {
        public override string name => "Stylized Pebbles";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/StylizedPebbles";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}
