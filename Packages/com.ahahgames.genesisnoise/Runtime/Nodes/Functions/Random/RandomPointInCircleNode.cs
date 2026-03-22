using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Random/Point in Circle")]
    public class RandomPointInCircleNode : ConstantNode
    {
        [Output]
        public Vector2 output;

        [Input]
        public Vector2 pt1 = new(0, 0);
        [Input]
        public float radius = 1;
        public override float nodeWidth => 200;
        public override string name => "Point in Circle";
        public override string NodeGroup => "Random";
        public override void Process()
        {
            output = Random.insideUnitCircle * radius + pt1;
        }

    }
}