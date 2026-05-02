using GraphProcessor;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Returns the square root of the input.
")]
    [System.Serializable, NodeMenuItem("Function/Math/Sqrt")]
    public class SqrtNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Output]
        public object output;

        public override string name => "Sqrt";
        public override string NodeGroup => "Math";

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (inputA == null)
            {
                output = null;
                return true;
            }

            output = Mathf.Sqrt(TypeCaster.ToFloat(inputA));
            return true;
        }
    }
}
