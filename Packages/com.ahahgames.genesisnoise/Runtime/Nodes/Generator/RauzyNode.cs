using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The Rauzy fractal is one of the most beautiful substitution‑system fractals, but unlike Mandelbrot/Julia, it’s not defined by complex iteration. It comes from:
- A substitution morphism on a symbolic sequence
- Projecting the symbolic orbit into \mathbb{R^{\mathnormal{2}}}
- Taking the closure of the resulting point set

")]

    [System.Serializable, NodeMenuItem("Generators/Other/Rauzy")]
    public class RauzyNode : FixedNoiseNode
    {
        public override string name => "Rauzy";
        public override string ShaderName => "Hidden/Genesis/RauzyFractal";
        public override string NodeGroup => "Other";
    }
}