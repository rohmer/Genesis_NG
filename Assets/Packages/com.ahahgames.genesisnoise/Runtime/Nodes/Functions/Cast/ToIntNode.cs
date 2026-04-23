using GraphProcessor;

using UnityEngine;


namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Casts the input value to Int.
")]

    [System.Serializable, NodeMenuItem("Function/Cast/To Int")]
    public class ToIntNode : ConstantNode
    {
        [Input]
        public object input;

        [Output]
        public int output;
        public override float nodeWidth => 200;
        public override string name => "To Int";
        public override string NodeGroup => "Cast";
        public override void Process()
        {
            output = TypeCasting.ToInt(output);
        }
    }
}
