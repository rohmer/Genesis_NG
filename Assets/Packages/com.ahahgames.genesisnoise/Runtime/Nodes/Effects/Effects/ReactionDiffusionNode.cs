using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 discrete reaction‑diffusion solver:
- Two fields: A (activator) and B (inhibitor)
- A diffuses slowly, B diffuses faster
- They react according to the Gray‑Scott equations
- After a number of iterations, you get:
- Spots
- Stripes
- Labyrinths
- Turing patterns

")]

    [System.Serializable, NodeMenuItem("Effects/Reaction Diffusion")]
    public class ReactionDiffusionNode : FixedNoiseNode
    {
        public override string name => "Reaction Diffusion";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/ReactionDiffusion";
    }
}