using GraphProcessor;


namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Outputs a constant string value.
")]

    [System.Serializable, NodeMenuItem("Function/Constant/String")]
    public class StringNode : ConstantNode
    {
        [Output]
        public string output = string.Empty;
        public override string name => "String";
        public override string NodeGroup => "Constant";
    }
}
