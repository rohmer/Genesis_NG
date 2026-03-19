using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Cast/To Int")]
    public class ToIntNode : ConstantNode
    {
        [Input]
        public object input;

        [Output]
        public int output;

        public override string name => "To Int";
        public override string NodeGroup => "Cast";
        public override void Process()
        {
            output = TypeCaster.ToInt(output);
        }
    }
}