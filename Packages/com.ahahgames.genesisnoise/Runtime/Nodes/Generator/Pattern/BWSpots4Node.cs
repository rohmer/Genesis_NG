using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
    Macro blots, micro speckles and watercolor diffusion
")]

    [System.Serializable, NodeMenuItem("Generators/Other/BW Spots 4")]
    public class BWSpots4Node : FixedNoiseNode
    {
        public override string name => "BW Spots 4";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/BWSpots4";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}