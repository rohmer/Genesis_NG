using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a Spynx Fractal, a fractal that is created by repeatedly applying a transformation to a point in the complex plane. The transformation is defined by the equation z = z^2 + c, where z is a complex number and c is a constant. The resulting pattern is self-similar and has a fractal dimension of 2.
")]

    [System.Serializable, NodeMenuItem("Generators/Other/Spynx Fractal")]
    public class SpynxFractalNode : FixedNoiseNode
    {
        public override string name => "Sphynx Fractal";
        public override string ShaderName => "Hidden/Genesis/SphynxFractal";
        public override string NodeGroup => "Other";
    }
}