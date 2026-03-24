using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The WhiteNoise node generates pure, uncorrelated white noise in 2D, 3D, or Cube space.
It is a lightweight, deterministic, sampler‑free noise source ideal for:
- Random masks
- Dithering
- Stochastic sampling
- Pattern breakup
- Randomized FX
- Seeded variation
- Debugging procedural graphs
The node supports single‑channel, RGB, and RGBA output modes.
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/White Noise")]
    public class WhiteNoise : FixedShaderNode
    {
        public override string name => "White Noise";


        public override string ShaderName => "Hidden/Genesis/WhiteNoise";

        public override bool DisplayMaterialInspector => true;

        // Enumerate the list of material properties that you don't want to be turned into a connectable port.
        protected override IEnumerable<string> filteredOutProperties => new string[] { };
        public override string NodeGroup => "Noise";


    }
}

