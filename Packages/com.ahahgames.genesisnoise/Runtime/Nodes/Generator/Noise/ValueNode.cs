using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Value Noise
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Value")]
    public class ValueNode : FixedNoiseNode
    {
        public override string name => "Value";

        public override string ShaderName => "Hidden/Genesis/ValueNoise_2D3D4D";
        public override string NodeGroup => "Noise";
    }
}