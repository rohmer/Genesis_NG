using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
    Creates a marbalized texture, including an option for further colorization.
")]

    [System.Serializable, NodeMenuItem("Generators/Other/Marble")]
    public class Marble : FixedNoiseNode
    {
        public override string name => "Marble";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/Marble";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}