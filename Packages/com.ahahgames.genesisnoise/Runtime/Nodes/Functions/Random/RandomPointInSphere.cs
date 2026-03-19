using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Random/Point in Sphere")]
    public class RandomPointInSphereNode : ConstantNode
    {
        [Output]
        public Vector3 output;

        public Vector3 pt1 = new(0, 0, 0);
        public float radius = 1f;

        public override string name => "Point in Sphere";
        public override string NodeGroup => "Random";
        public override float nodeWidth => 200;
        public override void Process()
        {
            output = Random.insideUnitSphere * radius + pt1;
        }

    }
}