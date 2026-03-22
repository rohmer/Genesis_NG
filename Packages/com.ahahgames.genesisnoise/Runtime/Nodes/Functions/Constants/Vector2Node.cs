using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Constant/Vector2")]
    public class Vector2Node : ConstantNode
    {
        [Output]
        public Vector2 output = new();
        [Output]
        public float X;
        public float Y;

        public override string name => "Vector2";
        public override string NodeGroup => "Constant";
    }
}