using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
This is not a texture lookup.
This is a true procedural scratch synthesizer:

Directional or chaotic
Adjustable density
Length, thickness, jitter
Breakup noise
Randomization seed
CRT‑safe (2D / 3D / Cube)
Deterministic, atomic‑free
")]

    [System.Serializable, NodeMenuItem("Generators/Pattern/Scratches Generator")]
    public class ScratchesGeneratorNode : FixedNoiseNode
    {
        public override string name => "Scratches Generator";
        public override string NodeGroup => "Pattern";
        public override string ShaderName => "Hidden/Genesis/ScratchesGenerator";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}