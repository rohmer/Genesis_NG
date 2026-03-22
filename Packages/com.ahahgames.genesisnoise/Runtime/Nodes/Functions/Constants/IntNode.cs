using GraphProcessor;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Constant/Integer")]
    public class IntNode : ConstantNode
    {
        [Output("Integer")]
        public int output = 0;
        public override string name => "Integer";
        public override string NodeGroup => "Constant";
    }
}