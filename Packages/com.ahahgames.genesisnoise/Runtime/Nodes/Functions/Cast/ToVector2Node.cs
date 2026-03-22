using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Cast/To Vector2")]
    public class ToVector2Node : ConstantNode
    {
        [Input]
        public object X, Y;

        [Output]
        public Vector2 output;
        public override float nodeWidth => 200;
        public override string name => "To Vector2";
        public override string NodeGroup => "Cast";
        public override void Process()
        {
            float x = TypeCaster.ToFloat(X);
            float y = TypeCaster.ToFloat(Y);
            output = new Vector2(x, y);
        }
    }
}