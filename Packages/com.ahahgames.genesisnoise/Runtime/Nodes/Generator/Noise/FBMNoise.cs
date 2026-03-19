using GraphProcessor;

using System.Collections.Generic;
using System.Linq;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/FBM")]
    public class FBMNoise : FixedNoiseNode
    {
        public override string name => "FBM Noise";

        public override string NodeGroup => "Noise";
        public override string ShaderName => "Hidden/Genesis/FBM";

        protected override IEnumerable<string> filteredOutProperties => base.filteredOutProperties.Concat(new string[] {
            "_FBMType",
            "_Lacunarity",
            "_Shift",
            "_TimeShift",
            "_FBMType",
            "_Mode",
            "_AxialShift",
            "_PowIntensity",
            "_Offset",
            "_Interp",
            "_Translate",
            "_WarpStrength",
            "_Width",
            "_Softness" });

    }
}