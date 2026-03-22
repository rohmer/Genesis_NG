using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System.Collections.Generic;

namespace Genesis
{
    [System.Serializable, NodeMenuItem("Generators/Shapes/Random N-Gon")]
    public class RandomNGonNode : FixedShaderNode
    {
        public override string name => "Random N-Gon Node";

        public override string ShaderName => "Hidden/Genesis/RandomNGon";

        public override bool DisplayMaterialInspector => true;

        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        protected override GenesisNoiseSettings defaultSettings => Get2DOnlyRTSettings(base.defaultSettings);

        // Override this if you node is not compatible with all dimensions
        public override List<OutputDimension> supportedDimensions => new() {
            OutputDimension.Texture2D,
        };
        public override string NodeGroup => "Shape";
    }
}