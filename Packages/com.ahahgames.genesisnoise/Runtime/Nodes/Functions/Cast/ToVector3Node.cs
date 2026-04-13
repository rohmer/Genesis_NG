using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Casts the input value to Vector3.
")]

    [System.Serializable, NodeMenuItem("Function/Cast/To Vector3")]
    public class ToVector3Node : ConstantNode
    {
        [Input]
        public object X, Y, Z;

        [Output]
        public Vector3 output;
        public override float nodeWidth => 200;
        public override string name => "To Vector3";
        public override string NodeGroup => "Cast";
        public override void Process()
        {
            float x, y, z;
            x = TypeCasting.ToFloat(X);
            y = TypeCasting.ToFloat(Y);
            z = TypeCasting.ToFloat(Z);

            output = new Vector3(x, y, z);
        }
    }
}
