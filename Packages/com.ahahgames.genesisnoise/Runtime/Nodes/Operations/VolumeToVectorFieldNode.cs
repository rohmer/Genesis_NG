using AhahGames.GenesisNoise.Graph;
using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

using System.Collections.Generic;

namespace Mixture
{
    [System.Serializable, NodeMenuItem("Operations/Volume To Vector Field")]
    public class VolumeToVectorFieldNode : FixedShaderNode
    {
        public override string name => "Volume To Vector Field";

        public override string ShaderName => "Hidden/Genesis/VolumeToVectorField";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        protected override GenesisNoiseSettings defaultSettings => base.Get3DOnlyRTSettings(base.defaultSettings);

        public override List<OutputDimension> supportedDimensions => new() {
            OutputDimension.Texture3D,
        };
    }
}