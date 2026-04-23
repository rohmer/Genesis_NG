using AhahGames.GenesisNoise.Graph;

using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Takes an input texture and converts it to a normal.  Usually used on a height map
")]

    [System.Serializable, NodeMenuItem("Normal/To Normal")]
    public class ToNormalNode : FixedShaderNode
    {
        public override string name => "Heightmap To Normal";

        public override string ShaderName => "Hidden/Genesis/HeightToNormal";

        public override string NodeGroup => "Normal";
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