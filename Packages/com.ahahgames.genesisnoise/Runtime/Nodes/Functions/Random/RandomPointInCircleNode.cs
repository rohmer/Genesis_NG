using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Random/Point in Circle")]
    public class RandomPointInCircleNode : ConstantNode
    {
        [Output]
        public Vector2 output;

        public Vector2 pt1 = new(0, 0);
        public float radius = 1;

        public override string name => "Point in Circle";
        public override string NodeGroup => "Random";
        public override float nodeWidth => GenesisNoiseUtility.smallNodeWidth;
        public override void Process()
        {
            output = Random.insideUnitCircle * radius + pt1;
        }

    }
}