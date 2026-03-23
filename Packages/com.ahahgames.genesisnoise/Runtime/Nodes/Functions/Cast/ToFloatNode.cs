using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Cast/To Float")]
    public class ToFloatNode : ConstantNode
    {
        [Input]
        public object input;

        [Output]
        public float output;
        public override float nodeWidth => 200;
        public override string name => "To Float";
        public override string NodeGroup => "Cast";
        public override void Process()
        {
            output = TypeCasting.ToFloat(input);
        }
    }
}