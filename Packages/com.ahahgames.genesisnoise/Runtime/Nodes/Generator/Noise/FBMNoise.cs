using GraphProcessor;

using System.Collections.Generic;
using System.Linq;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The FBM node generates fractal noise by layering multiple octaves of a base noise function.
Unlike traditional FBM nodes, this version supports five distinct FBM types, each with its own parameters and behaviors:
- Value FBM
- Perlin FBM
- Voronoi FBM
- Grid FBM
- Meatball FBM (metaball‑based)
This makes the node extremely versatile for:
- Terrain
- Clouds
- Stylized materials
- Organic patterns
- Domain‑warped textures
- Masks and breakup layers
- Procedural animation
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