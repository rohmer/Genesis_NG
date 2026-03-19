using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System.Collections.Generic;

namespace Genesis
{
    [System.Serializable, NodeMenuItem("Generators/Shapes/Polygon 2D")]
    public class Polygon2DNode : FixedShaderNode
    {
        public override string name => "Polygon Node";

        public override string ShaderName => "Hidden/Genesis/Polygon2D";

        public override bool DisplayMaterialInspector => true;

        protected override IEnumerable<string> filteredOutProperties => new string[] { "_Starryness", "_Mode" };

        protected override GenesisNoiseSettings defaultSettings => Get2DOnlyRTSettings(base.defaultSettings);

        // Override this if you node is not compatible with all dimensions
        public override List<OutputDimension> supportedDimensions => new() {
            OutputDimension.Texture2D,
        };
    }
}