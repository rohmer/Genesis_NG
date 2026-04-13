using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Outputs a constant vector3int value.
")]

    [System.Serializable, NodeMenuItem("Function/Constant/Vector3Int")]
    public class Vector3IntNode : ConstantNode
    {
        [Output]
        public Vector3Int output = new();
        [Output]
        public int X;
        [Output]
        public int Y;
        [Output]
        public int Z;

        public override string name => "Vector3Int";
        public override float nodeWidth => 210;
        public override string NodeGroup => "Constant";
    }
}
