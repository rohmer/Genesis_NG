using AhahGames.GenesisNoise.Graph;

using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
A tiling-safe version of Transform 2D inspired by Substance Designer's Safe Transform node.

It lets you tile, offset, rotate, mirror, and optionally fill out-of-bounds space without the usual softening you get from tiny sub-pixel moves.

This version focuses on the core Safe Transform workflow:
- Tile count
- Manual or pseudo-random offset
- Rotation in turns
- Optional safe rotation snapping
- X / Y symmetry
- Manual mip selection for sharper minified results
")]
    [System.Serializable, NodeMenuItem("Transform/Safe Transform")]
    public class SafeTransformNode : FixedNoiseNode
    {
        public override string name => "Safe Transform";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/SafeTransform";

        protected override GenesisNoiseSettings defaultSettings => Get2DOnlyRTSettings(base.defaultSettings);

        public override List<OutputDimension> supportedDimensions => new()
        {
            OutputDimension.Texture2D,
        };
    }
}
