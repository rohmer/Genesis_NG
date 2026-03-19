using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Cast/To Quaternion")]
    public class ToQuaternionNode : ConstantNode
    {
        [Input(name = "Euler X")]
        public float EulerX;
        [Input(name = "Euler Y")]
        public float EulerY;
        [Input(name = "Euler Z")]
        public float EulerZ;

        [Output]
        public Quaternion output;

        public new float nodeWidth = 200f;
        public override string name => "To Quaternion";
        public override string NodeGroup => "Cast";
        public override void Process()
        {
            output = Quaternion.Euler(EulerX, EulerY, EulerZ);
        }
    }
}