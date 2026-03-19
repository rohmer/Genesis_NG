using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Cast/To Color")]
    public class ToColorNode : ConstantNode
    {
        [Input]
        public float R, G, B, A;

        [Output]
        public Color output;

        public override string name => "To Color";
        public override string NodeGroup => "Cast";
        public override void Process()
        {
            output = new Color(R, G, B, A);
        }
    }
}