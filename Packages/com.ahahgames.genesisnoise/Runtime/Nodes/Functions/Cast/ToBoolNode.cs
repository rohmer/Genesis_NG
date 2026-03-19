using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Cast/To Boolean")]
    public class ToBoolNode : ConstantNode
    {
        [Input]
        public object input;

        [Output]
        public bool output;

        public override string name => "To Boolean";
        public override string NodeGroup => "Cast";

        public override void Process()
        {
            output = TypeCaster.ToBool(input);

        }
    }
}