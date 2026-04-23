using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates two different mandlebrot fractals
")]

    [System.Serializable, NodeMenuItem("Generators/Other/Mandelbrot")]
    public class MandelbrotNode : FixedNoiseNode
    {
        public override string name => "Mandlebrot";
        public override string ShaderName => "Hidden/Genesis/Mandelbrot";
        public override string NodeGroup => "Other";
    }
}