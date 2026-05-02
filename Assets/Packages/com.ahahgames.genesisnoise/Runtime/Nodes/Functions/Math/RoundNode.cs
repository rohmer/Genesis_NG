using GraphProcessor;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Rounds the input to the nearest integer value.
")]
    [System.Serializable, NodeMenuItem("Function/Math/Round")]
    public class RoundNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Output]
        public object output;

        public override string name => "Round";
        public override string NodeGroup => "Math";

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (inputA == null)
            {
                output = null;
                return true;
            }

            output = Mathf.Round(TypeCaster.ToFloat(inputA));
            return true;
        }
    }
}
