using System;

using GraphProcessor;

using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Returns the hyperbolic cosine of the input.
")]
    [System.Serializable, NodeMenuItem("Function/Math/Cosh")]
    public class CoshNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Output]
        public object output;

        public override string name => "Cosh";
        public override string NodeGroup => "Math";

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (inputA == null)
            {
                output = null;
                return true;
            }

            output = MathF.Cosh(TypeCaster.ToFloat(inputA));
            return true;
        }
    }
}
