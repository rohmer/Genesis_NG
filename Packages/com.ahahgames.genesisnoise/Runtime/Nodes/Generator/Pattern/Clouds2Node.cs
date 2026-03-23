using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
    Sharper, higher-contrast and more turbulent sibling of clouds 1
")]

    [System.Serializable, NodeMenuItem("Generators/Other/Clouds 2")]
    public class Clouds2Node : FixedNoiseNode
    {
        public override string name => "Clouds 2";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Clouds2";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}