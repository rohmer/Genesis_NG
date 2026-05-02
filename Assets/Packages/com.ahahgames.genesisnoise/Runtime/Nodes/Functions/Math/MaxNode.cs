using System;

using GraphProcessor;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Returns the larger of the input values.
")]
    [System.Serializable, NodeMenuItem("Function/Math/Max")]
    public class MaxNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Input(name = "B")]
        public object inputB;

        [Output]
        public object output;

        public override string name => "Max";
        public override string NodeGroup => "Math";

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (MathOperationUtility.TryPassthroughMissingBinaryInput(inputA, inputB, out output))
                return true;

            output = MathOperationUtility.ApplyBinaryOperation(
                inputA,
                inputB,
                (t1, t2) => t1 || t2,
                (t1, t2) => MathF.Max(t1, t2),
                (t1, t2) => Mathf.Max(t1, t2),
                (t1, t2) => t1.Length >= t2.Length ? t1 : t2);

            return true;
        }
    }
}
