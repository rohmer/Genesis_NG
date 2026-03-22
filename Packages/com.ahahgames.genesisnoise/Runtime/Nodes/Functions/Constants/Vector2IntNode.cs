using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Constant/Vector2Int")]
    public class Vector2IntNode : ConstantNode
    {
        [Output]
        public Vector2Int output = new();
        [Output]
        public int X;
        [Output]
        public int Y;

        public override string name => "Vector2Int";

        public override string NodeGroup => "Constant";
        public override float nodeWidth => 200;
    }
}