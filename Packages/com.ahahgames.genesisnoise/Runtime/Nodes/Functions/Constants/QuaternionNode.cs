using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Outputs a constant quaternion value.
")]

    [System.Serializable, NodeMenuItem("Function/Constant/Quaternion")]
    public class QuaternionNode : ConstantNode
    {
        [Output("Quaternion")]
        public Quaternion output = new();
        [Output]
        public float X;
        [Output]
        public float Y;
        [Output]
        public float Z;
        [Output]
        public float W;
        public override string name => "Quaternion";
        public override float nodeWidth => 210;
        public override string NodeGroup => "Constant";
    }
}
