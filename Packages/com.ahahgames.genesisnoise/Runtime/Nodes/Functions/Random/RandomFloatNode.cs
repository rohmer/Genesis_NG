using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a random float value.
")]

    [System.Serializable, NodeMenuItem("Function/Random/Float")]
    public class RandomFloatNode : ConstantNode
    {
        [Output]
        public float output = 0f;

        [Input]
        public float min = 0f, max = 1f;

        public override string name => "Random Float";
        public override string NodeGroup => "Random";
        public override float nodeWidth => 200;

        public override void Process()
        {
            output = Random.Range(min, max);
        }

    }
}
