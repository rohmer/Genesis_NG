using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Constant/Vector4")]
    public class Vector4Node : ConstantNode
    {
        [Output]
        public Vector4 output = new();
        [Output]
        public float X;
        [Output]
        public float Y;
        [Output]
        public float Z;
        [Output]
        public float W;

        public override string name => "Vector4";
        public override float nodeWidth => 210;

    }
}