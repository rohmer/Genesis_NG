using System;

using GraphProcessor;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Returns the smaller of the input values.
")]
    [System.Serializable, NodeMenuItem("Function/Math/Min")]
    public class MinNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Input(name = "B")]
        public object inputB;

        [Output]
        public object output;

        public override string name => "Min";
        public override string NodeGroup => "Math";

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (MathOperationUtility.TryPassthroughMissingBinaryInput(inputA, inputB, out output))
                return true;

            output = MathOperationUtility.ApplyBinaryOperation(
                inputA,
                inputB,
                (t1, t2) => t1 && t2,
                (t1, t2) => MathF.Min(t1, t2),
                (t1, t2) => Mathf.Min(t1, t2),
                (t1, t2) => t1.Length <= t2.Length ? t1 : t2);

            return true;
        }
    }
}
