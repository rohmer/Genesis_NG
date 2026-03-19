using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Simulates fur on a texture, color based on another texture
")]

    [System.Serializable, NodeMenuItem("Effects/Modifications/Fur")]
    public class FurNode : FixedNoiseNode
    {
        public override string name => "Fur";
        public override string NodeGroup => "Modifiers";
        public override string ShaderName => "Hidden/Genesis/Fur";
    }
}