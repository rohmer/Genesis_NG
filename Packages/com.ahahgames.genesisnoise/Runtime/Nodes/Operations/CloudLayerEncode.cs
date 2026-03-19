using AhahGames.GenesisNoise.Graph;

using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Encodes a Cubemap texture into a 2D map, the output texture is formated for the HDRP cloud layer system (latlong).
")]

    [System.Serializable, NodeMenuItem("Operations/Cloud Layer Encode")]
    public class CloudLayerEncode : FixedShaderNode
    {
        public override string name => "Cloud Layer Encode";

        public override string ShaderName => "Hidden/Genesis/CloudLayerEncode";
        public override string NodeGroup => "Operations";
        public override bool DisplayMaterialInspector => true;

        protected override GenesisNoiseSettings defaultSettings => Get2DOnlyRTSettings(base.defaultSettings);

        protected override IEnumerable<string> filteredOutProperties => new string[] { "_UpperHemisphereOnly" };

        // Override this if you node is not compatible with all dimensions
        public override List<OutputDimension> supportedDimensions => new() {
            OutputDimension.Texture2D,
        };
    }
}