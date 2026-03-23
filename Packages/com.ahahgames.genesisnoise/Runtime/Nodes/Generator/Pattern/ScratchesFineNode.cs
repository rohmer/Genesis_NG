using GraphProcessor;

using System.Collections.Generic;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- Deterministic hash‑based noise
- Fine, dense, hairline scratches
- Micro‑directional breakup
- Soft dirt accumulation for depth
- Adjustable contrast and breakup

")]

    [System.Serializable, NodeMenuItem("Generators/Other/Scratches Fine")]
    public class ScratchesFineNode : FixedNoiseNode
    {
        public override string name => "Scratches Fine";
        public override string NodeGroup => "Generators";
        public override string ShaderName => "Hidden/Genesis/GrungeScratchesFine";
        protected override IEnumerable<string> filteredOutProperties => new string[] { };

        public override float nodeWidth => 300;
    }
}