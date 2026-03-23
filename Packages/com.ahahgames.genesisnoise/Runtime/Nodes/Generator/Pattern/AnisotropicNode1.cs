using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
    Long, directional fibers that follow a rotation angle
")]

    [System.Serializable, NodeMenuItem("Generators/Other/Anisotropic Noise 1")]
    public class AnisotropicNode1 : FixedNoiseNode
    {
        public override string name => "Anisotropic";
        public override string NodeGroup => "Generators";
        public override string ShaderName => "Hidden/Genesis/AnisotropicNoise";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}