using GraphProcessor;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Adds the input values.
")]
    [System.Serializable, NodeMenuItem("Function/Math/Addition")]
    public class AddNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Input(name = "B")]
        public object inputB;

        [Output(name = "Output")]
        public object output;

        public override string name => "Addition";
        public override string NodeGroup => "Math";

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (MathOperationUtility.TryPassthroughMissingBinaryInput(inputA, inputB, out output))
                return true;

            output = MathOperationUtility.ApplyBinaryOperation(
                inputA,
                inputB,
                (t1, t2) => t1 || t2,
                (t1, t2) => t1 + t2,
                (t1, t2) => t1 + t2,
                (t1, t2) => t1 + t2);

            return true;
        }
    }
}
