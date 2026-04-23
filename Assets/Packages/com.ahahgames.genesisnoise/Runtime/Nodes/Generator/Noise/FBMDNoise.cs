using GraphProcessor;

using System.Collections.Generic;
using System.Linq;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The FBMD node generates multi‑dimensional fractal noise, outputting three correlated channels (X, Y, Z).
It supports two base noise types:
- Value FBMD
- Perlin FBMD
Unlike standard FBM, which outputs a single scalar, FBMD produces a vector‑like triple of fractal values.
This makes it ideal for:
- Vector displacement
- Flow fields
- Stylized normals
- Multi‑channel masks
- Procedural breakup
- Organic motion fields
- Terrain and material layering
The node also includes slopeness, a unique parameter that shapes the directional bias of the fractal layers.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Derivative FBM")]
    public class FBMDNoise : FixedNoiseNode
    {
        public override string name => "Derivitive FBM Noise";

        public override string NodeGroup => "Noise";
        public override string ShaderName => "Hidden/Genesis/FBMD";        
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