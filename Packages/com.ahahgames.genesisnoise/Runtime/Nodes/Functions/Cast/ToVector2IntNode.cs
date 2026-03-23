using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Cast/To Vector2Int")]
    public class ToVector2IntNode : ConstantNode
    {
        [Input]
        public object X, Y;

        [Output]
        public Vector2Int output;
        public override float nodeWidth => 200;
        public override string name => "To Vector2Int";
        public override string NodeGroup => "Cast";
        public override void Process()
        {
            int x = TypeCasting.ToInt(X);
            int y = TypeCasting.ToInt(Y);
            output = new Vector2Int(x, y);
        }
    }
}
