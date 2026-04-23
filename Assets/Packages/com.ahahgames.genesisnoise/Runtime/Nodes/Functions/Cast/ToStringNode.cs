using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Casts the input value to String.
")]

    [System.Serializable, NodeMenuItem("Function/Cast/To String")]
    public class ToStringNode : ConstantNode
    {
        [Input]
        public object input;

        [Output]
        public string output;
        public override float nodeWidth => 200;
        public override string name => "To String";
        public override string NodeGroup => "Cast";
        public override void Process()
        {
            output = TypeCasting.ToString(input);
        }
    }
}
