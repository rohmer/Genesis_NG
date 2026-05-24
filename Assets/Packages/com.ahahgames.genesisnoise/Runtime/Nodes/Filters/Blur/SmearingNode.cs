using AhahGames.GenesisNoise.Graph;

using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Substance-style smearing driven by a grayscale slope map.

The filter traces samples along the local slope direction and combines them with the selected mode:
- Maximum smears bright detail outward
- Minimum smears dark detail outward
- Average produces a softer blur-like trail

Useful for:
- Pulled paint and clay streaks
- Dragged dirt and rust masks
- Height-based chipping and directional breakup
")]
    [System.Serializable, NodeMenuItem("Filters/Blur/Smearing")]
    public class SmearingNode : FixedShaderNode
    {
        public override string name => "Smearing";
        public override string NodeGroup => "Blur";
        public override string ShaderName => "Hidden/Genesis/Smearing";
        public override bool DisplayMaterialInspector => true;

        protected override GenesisNoiseSettings defaultSettings => Get2DOnlyRTSettings(base.defaultSettings);

        public override List<OutputDimension> supportedDimensions => new()
        {
            OutputDimension.Texture2D,
        };
    }
}
