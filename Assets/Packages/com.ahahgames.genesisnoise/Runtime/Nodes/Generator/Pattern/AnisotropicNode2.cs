using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
     streaks + turbulence + cross‑flow, closer to a noisy brushed metal / fibrous chaos.
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Anisotropic Noise 2")]
    public class AnisotropicNode2 : FixedNoiseNode
    {
        public override string name => "Anisotropic Pattern 2";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/AnisotropicNoise2";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}