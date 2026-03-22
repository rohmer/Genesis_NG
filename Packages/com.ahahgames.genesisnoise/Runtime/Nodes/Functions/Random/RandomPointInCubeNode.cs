using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Random/Point in Cube")]
    public class RandomPointInCubeNode : ConstantNode
    {
        [Output]
        public Vector3 output;

        [Input]
        public Vector3 pt1 = new(-1, -1, -1);
        [Input]
        public Vector3 pt2 = new(1, 1, 1);

        public override string name => "Point in Cube";
        public override string NodeGroup => "Random";
        public override float nodeWidth => 200;
        public override void Process()
        {
            float minX = Mathf.Min(pt1.x, pt2.x);
            float minY = Mathf.Min(pt1.y, pt2.y);
            float maxX = Mathf.Max(pt1.x, pt2.x);
            float maxY = Mathf.Max(pt1.y, pt2.y);
            float minZ = Mathf.Min(pt1.z, pt2.z);
            float maxZ = Mathf.Max(pt1.z, pt2.z);
            output = new Vector3(
                Random.Range(minX, maxX),
                Random.Range(minY, maxY),
                Random.Range(minZ, maxZ)
            );
        }

    }
}