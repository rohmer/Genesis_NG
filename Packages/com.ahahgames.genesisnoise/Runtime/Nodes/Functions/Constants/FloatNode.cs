using GraphProcessor;


namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Outputs a constant float value.
")]

    [System.Serializable, NodeMenuItem("Function/Constant/Float")]
    public class FloatNode : ConstantNode
    {
        [Output("Float")]
        public float output = 0.0f;
        public override string name => "Float";
        public override string NodeGroup => "Constant";
    }
}
