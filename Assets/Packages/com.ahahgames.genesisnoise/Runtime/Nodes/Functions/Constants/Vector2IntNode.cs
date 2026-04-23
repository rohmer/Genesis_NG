using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Outputs a constant vector2int value.
")]

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
