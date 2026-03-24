using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
    More randomized and curled scratches
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/OrganicScratches")]
    public class OrganicScratchesNode : FixedNoiseNode
    {
        public override string name => "Organic Scratches";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/OrganicScratches";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}