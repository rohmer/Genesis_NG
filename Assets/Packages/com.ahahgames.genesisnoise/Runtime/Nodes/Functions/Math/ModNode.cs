using GraphProcessor;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Returns the remainder of A divided by B.
")]
    [System.Serializable, NodeMenuItem("Function/Math/Mod")]
    public class ModNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Input(name = "B")]
        public object inputB;

        [Output]
        public object output;

        public override string name => "Mod";
        public override string NodeGroup => "Math";

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (MathOperationUtility.TryPassthroughMissingBinaryInput(inputA, inputB, out output))
                return true;

            output = MathOperationUtility.ApplyBinaryOperation(
                inputA,
                inputB,
                (t1, t2) => t1 && !t2,
                (t1, t2) => Mathf.Approximately(t2, 0f) ? 0f : t1 % t2,
                (t1, t2) => t2 == 0 ? 0 : t1 % t2,
                (t1, t2) => t1 + "%" + t2);

            return true;
        }
    }
}
