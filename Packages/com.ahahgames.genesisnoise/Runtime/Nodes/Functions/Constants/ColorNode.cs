using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Outputs a constant color value.
")]

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
        public override string NodeGroup => "Constant";
    }
}
