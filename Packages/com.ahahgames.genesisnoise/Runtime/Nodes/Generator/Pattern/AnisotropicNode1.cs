using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
    A compact Genesis CRT node that generates anisotropic procedural noise suitable for streaks, brushed surfaces, wood grain, and directional fabric. It produces a single grayscale output where brighter values represent higher noise intensity. The node is deterministic, CRT‑friendly, and designed to be used as a texture source inside Genesis graphs or as a mask/height input for material blending.
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Anisotropic Noise 1")]
    public class AnisotropicNode1 : FixedNoiseNode
    {
        public override string name => "Anisotropic";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/AnisotropicNoise";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}