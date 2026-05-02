using AhahGames.GenesisNoise.Graph;

using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Applies a low-poly polygonization effect by triangulating the source image into jittered cells and simplifying the color inside each triangle.
")]
    [UnityEngine.Scripting.APIUpdating.MovedFrom(false, sourceNamespace: "AhahGames.GenesisNoise.Nodes", sourceAssembly: "Genesis Noise", sourceClassName: "PoliginizationNode")]
    [System.Serializable, NodeMenuItem("Effects/Poliginize"), NodeMenuItem("Effects/Polygonize")]
    public class PolygonizeNode : FixedNoiseNode
    {
        public override string name => "Polygonize";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/Poliginization";

        protected override GenesisNoiseSettings defaultSettings => Get2DOnlyRTSettings(base.defaultSettings);

        public override List<OutputDimension> supportedDimensions => new() {
            OutputDimension.Texture2D,
        };
    }
}
