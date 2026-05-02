using GraphProcessor;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Returns the arctangent of the input.
")]
    [System.Serializable, NodeMenuItem("Function/Math/Atan")]
    public class AtanNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Output]
        public object output;

        public override string name => "Atan";
        public override string NodeGroup => "Math";

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (inputA == null)
            {
                output = null;
                return true;
            }

            output = Mathf.Atan(TypeCaster.ToFloat(inputA));
            return true;
        }
    }
}
