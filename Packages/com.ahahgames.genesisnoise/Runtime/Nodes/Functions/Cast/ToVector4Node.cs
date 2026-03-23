using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Cast/To Vector4")]
    public class ToVector4Node : ConstantNode
    {
        [Input]
        public object X, Y, Z, W;

        [Output]
        public Vector4 output;
        public override float nodeWidth => 200;
        public override string name => "To Vector4";
        public override string NodeGroup => "Cast";
        public override void Process()
        {
            float x, y, z, w;
            x = TypeCasting.ToFloat(X);
            y = TypeCasting.ToFloat(Y);
            z = TypeCasting.ToFloat(Z);
            w = TypeCasting.ToFloat(W);
            output = new Vector4(x, y, z, w);
        }
    }
}