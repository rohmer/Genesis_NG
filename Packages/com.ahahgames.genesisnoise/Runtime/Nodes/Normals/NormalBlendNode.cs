using AhahGames.GenesisNoise.Graph;

using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Blends two normals
")]

    [System.Serializable, NodeMenuItem("Normal/Normal Blend")]
    public class NormalBlendNode : FixedShaderNode
    {
        public override string name => "Normal Blend";

        public override string ShaderName => "Hidden/Genesis/NormalBlend";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        protected override GenesisNoiseSettings defaultSettings => Get2DOnlyRTSettings(base.defaultSettings);

        // Override this if you node is not compatible with all dimensions
        public override List<OutputDimension> supportedDimensions => new() {
            OutputDimension.Texture2D,
        };
    }
}