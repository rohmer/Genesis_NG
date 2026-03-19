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

        public override string name => "To Vector2Int";
        public override string NodeGroup => "Cast";
        public override void Process()
        {
            int x = TypeCaster.ToInt(X);
            int y = TypeCaster.ToInt(Y);
            output = new Vector2Int(x, y);
        }
    }
}
