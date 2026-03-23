using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
- A single soft Gaussian blob per cell
- Deterministic, sampler‑free
- Fully procedural
- Perfect as a building block for grunge, masks, breakup, height maps
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Gaussian Cells")]
    public class GaussianSingleNode : FixedNoiseNode
    {
        public override string name => "Gaussian Cells";
        public override string ShaderName => "Hidden/Genesis/Gaussian1";
        public override string NodeGroup => "Shape";
    }
}