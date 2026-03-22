using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Cast/To Vector3Int")]
    public class ToVector3IntNode : ConstantNode
    {
        [Input] object X, Y, Z;

        [Output]
        public Vector3Int output;
        public override float nodeWidth => 200;
        public override string name => "To Vector3Int";
        public override string NodeGroup => "Cast";
        public override void Process()
        {
            int x, y, z;
            x = TypeCaster.ToInt(X);
            y = TypeCaster.ToInt(Y);
            z = TypeCaster.ToInt(Z);
            output = new Vector3Int(x, y, z);
        }
    }
}
