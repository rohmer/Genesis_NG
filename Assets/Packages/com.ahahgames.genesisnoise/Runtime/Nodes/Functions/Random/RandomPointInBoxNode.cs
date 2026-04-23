using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a random point inside a box.
")]

    [System.Serializable, NodeMenuItem("Function/Random/Point in Box")]
    public class RandomPointInBoxNode : ConstantNode
    {
        [Output]
        public Vector2 output;

        [Input]
        public Vector2 pt1 = new(-1, -1);
        [Input]
        public Vector2 pt2 = new(1, 1);
        public override float nodeWidth => 200;
        public override string name => "Point in Box";
        public override string NodeGroup => "Random";        
        public override void Process()
        {
            float minX = Mathf.Min(pt1.x, pt2.x);
            float minY = Mathf.Min(pt1.y, pt2.y);
            float maxX = Mathf.Max(pt1.x, pt2.x);
            float maxY = Mathf.Max(pt1.y, pt2.y);
            output = new Vector2(
                Random.Range(minX, maxX),
                Random.Range(minY, maxY)
            );
        }

    }
}
