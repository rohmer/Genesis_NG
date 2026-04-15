using AhahGames.GenesisNoise.Graph;

using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Applies a low-poly polygonization effect by triangulating the source image into jittered cells and simplifying the color inside each triangle.
")]

    [System.Serializable, NodeMenuItem("Effects/Poliginize"), NodeMenuItem("Effects/Polygonize")]
    public class PoliginizationNode : FixedNoiseNode
    {
        public override string name => "Poliginization";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/Poliginization";

        protected override GenesisNoiseSettings defaultSettings => Get2DOnlyRTSettings(base.defaultSettings);

        public override List<OutputDimension> supportedDimensions => new() {
            OutputDimension.Texture2D,
        };
    }
}
