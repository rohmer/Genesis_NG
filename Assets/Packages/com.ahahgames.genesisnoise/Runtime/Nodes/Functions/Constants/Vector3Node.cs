using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Outputs a constant vector3 value.
")]

    [System.Serializable, NodeMenuItem("Function/Constant/Vector3")]
    public class Vector3Node : ConstantNode
    {
        [Output]
        public Vector3 output = new();
        [Output]
        public float X;
        [Output]
        public float Y;
        [Output]
        public float Z;

        public override string name => "Vector3";
        public override float nodeWidth => 210;
        public override string NodeGroup => "Constant";
    }
}
