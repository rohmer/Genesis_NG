using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Simplex noise
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Simplex 3D")]
    public class Simplex3DNode : FixedNoiseNode
    {
        public override string name => "Simplex Noise 3D";

        public override string ShaderName => "Hidden/Genesis/Simplex3D";
        public override string NodeGroup => "Noise";
    }
}