using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Constant/Color")]
    public class ColorNode : ConstantNode
    {
        [Output(name ="Color")]
        public Color output = Color.black;
        [Output]
        public float Red;
        [Output]
        public float Green;
        [Output]
        public float Blue;
        [Output]
        public float Alpha;

        public override string name => "Color";

        public override float nodeWidth => 150f;

    }
}