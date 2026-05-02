using System;

using GraphProcessor;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Returns the logarithm of the input.
")]
    [System.Serializable, NodeMenuItem("Function/Math/Log")]
    public class LogNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Input(name = "B")]
        public object inputB;

        [Output]
        public object output;

        public override string name => "Log";
        public override string NodeGroup => "Math";

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (MathOperationUtility.TryPassthroughMissingBinaryInput(inputA, inputB, out output))
                return true;

            output = MathOperationUtility.ApplyBinaryOperation(
                inputA,
                inputB,
                (t1, t2) => t1,
                (t1, t2) => MathF.Log(t1, t2),
                (t1, t2) => (int)MathF.Log(t1, t2),
                (t1, t2) => t1 + "log" + t2);

            return true;
        }
    }
}
