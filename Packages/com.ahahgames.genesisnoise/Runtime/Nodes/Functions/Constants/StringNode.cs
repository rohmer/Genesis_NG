using GraphProcessor;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Constant/String")]
    public class StringNode : ConstantNode
    {
        [Output]
        public string output = string.Empty;
        public override string name => "String";

    }
}