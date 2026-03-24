using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Height Extrusion is the backbone of:
- bevel‑like height shaping
- directional emboss
- silhouette expansion
- stylized height growth
- mask inflation
- directional erosion/inset (with invert)
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Height Extrusion")]
    public class HeightExtrudeNode : FixedNoiseNode
    {
        public override string name => "Height Extrusion";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/HeightExtrude";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 325;
    }
}