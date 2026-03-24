using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
     - Soft, flowing turbulence
    - Directional streaks blended with cellular breakup
    - Painterly, cloud‑like gradients
    - Organic flow and drift
    - Less “fibers,” more “volumetric structure”
    - Perfect for stylized clouds, marble, smoke, roughness breakup
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Anisotropic Noise 3")]
    public class AnisotropicNode3 : FixedNoiseNode
    {
        public override string name => "Anisotropic 3";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/AnisotropicNoise3";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}