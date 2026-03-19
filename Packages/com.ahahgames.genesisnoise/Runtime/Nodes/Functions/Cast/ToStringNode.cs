using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Cast/To String")]
    public class ToStringNode : ConstantNode
    {
        [Input]
        public object input;

        [Output]
        public string output;

        public override string name => "To String";
        public override string NodeGroup => "Cast";
        public override void Process()
        {
            output = TypeCaster.ToString(input);
        }
    }
}