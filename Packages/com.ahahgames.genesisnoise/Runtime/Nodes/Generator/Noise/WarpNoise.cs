using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Creates noise that has a warped characteristic
")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Warp Noise"), NodeMenuItem("Effects/Modifications/Warp Noise")]
    public class WarpNoise : FixedNoiseNode
    {
        public override string NodeGroup => "Noise";
        public override string name => "Warp";        
        public override string ShaderName => "Hidden/Genesis/WarpNoise";
    }
}