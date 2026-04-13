using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Casts the input value to Boolean.
")]

    [System.Serializable, NodeMenuItem("Function/Cast/To Boolean")]
    public class ToBoolNode : ConstantNode
    {
        [Input]
        public object input;

        [Output]
        public bool output;

        public override string name => "To Boolean";
        public override string NodeGroup => "Cast";
        public override float nodeWidth =>200;
        public override void Process()
        {
            output = TypeCasting.ToBool(input);

        }
    }
}
