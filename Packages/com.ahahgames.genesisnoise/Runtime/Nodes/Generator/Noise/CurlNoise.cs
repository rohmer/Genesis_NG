using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Curl noise is similar math to the Perlin Noise, but with the addition of a curl function which allows it to generate a turbulent noise.
This resulting noise is incompressible (divergence-free), which means that the genearted vectors cannot converge to sink points.

The output of this node is a 2D or 3D vector field (normalized vector direction).
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Curl Noise")]
    public class CurlNoise : FixedNoiseNode
    {
        public override string ShaderName => "Hidden/Genesis/CurlNoise";

        public override string name => "Curl Noise";
    }
}