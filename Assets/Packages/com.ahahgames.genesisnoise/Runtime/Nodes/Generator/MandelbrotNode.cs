using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates two different Mandelbrot fractals
")]

    [System.Serializable, NodeMenuItem("Generators/Other/Mandelbrot")]
    public class MandelbrotNode : FixedNoiseNode
    {
        public override string name => "Mandelbrot";
        public override string ShaderName => "Hidden/Genesis/Mandelbrot";
        public override string NodeGroup => "Other";
    }
}
