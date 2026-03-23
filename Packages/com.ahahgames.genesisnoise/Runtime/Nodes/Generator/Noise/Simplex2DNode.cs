using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Simplex noise
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Simplex 2D")]
    public class Simplex2DNode : FixedNoiseNode
    {
        public override string name => "Simplex Noise 2D";

        public override string ShaderName => "Hidden/Genesis/Simplex2D";
        public override string NodeGroup => "Noise";
    }
}