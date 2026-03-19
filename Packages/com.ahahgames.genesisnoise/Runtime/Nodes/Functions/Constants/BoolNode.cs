using GraphProcessor;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Constant/Boolean")]
    public class BoolNode : ConstantNode
    {
        [Output(name = "Boolean")]
        public bool output = true;
        public override string name => "Boolean";
        public override float nodeWidth => 150f;

    }
}