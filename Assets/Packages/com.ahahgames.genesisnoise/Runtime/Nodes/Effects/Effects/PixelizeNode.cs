using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Pixelization node with scan line support
")]

    [System.Serializable, NodeMenuItem("Effects/Pixelize")]
    public class PixelizeNode : FixedNoiseNode
    {
        public override string name => "Pixelize";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/Pixelize";
    }
}