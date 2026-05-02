using System;

using GraphProcessor;

using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Returns the hyperbolic tangent of the input.
")]
    [System.Serializable, NodeMenuItem("Function/Math/Tanh")]
    public class TanhNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Output]
        public object output;

        public override string name => "Tanh";
        public override string NodeGroup => "Math";

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (inputA == null)
            {
                output = null;
                return true;
            }

            output = MathF.Tanh(TypeCaster.ToFloat(inputA));
            return true;
        }
    }
}
