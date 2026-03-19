using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Blur based on input noise, where input is the amount of bluring
")]

    [System.Serializable, NodeMenuItem("Effects/Blur/Noise Blur")]
    public class NoiseBlur : FixedNoiseNode
    {
        public override string name => "Noise Field Blur";
        public override string NodeGroup => "Blur";
        public override string ShaderName => "Hidden/Genesis/NoiseBlur";
    }
}