using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Random/Integer")]
    public class RandomIntNode : ConstantNode
    {
        [Output]
        public int output = 0;

        [Input]
        public int min = 0, max = 1;
        public override float nodeWidth => 200;
        public override string name => "Random Integer";
        public override string NodeGroup => "Random";
        public override void Process()
        {
            output = Random.Range(min, max);
        }

    }
}