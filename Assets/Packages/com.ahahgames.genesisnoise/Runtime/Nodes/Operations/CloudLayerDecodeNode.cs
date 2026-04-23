using AhahGames.GenesisNoise.Graph;

using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Decodes a 2D texture into a cubemap, the input texture has to be formated for the HDRP cloud layer system (latlong).
")]

    [System.Serializable, NodeMenuItem("Operations/Cloud Layer Decode")]
    public class CloudLayerDecode : FixedShaderNode
    {
        public override string name => "Cloud Layer Decode";

        public override string ShaderName => "Hidden/Genesis/CloudLayerDecode";
        public override string NodeGroup => "Operations";
        public override bool DisplayMaterialInspector => true;

        protected override GenesisNoiseSettings defaultSettings => GetCubeOnlyRTSettings(base.defaultSettings);

        protected override IEnumerable<string> filteredOutProperties => new string[] { "_UpperHemisphereOnly" };

        // Override this if you node is not compatible with all dimensions
        public override List<OutputDimension> supportedDimensions => new() {
            OutputDimension.CubeMap,
        };
    }
}