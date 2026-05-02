using System;

using GraphProcessor;

using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Returns the hyperbolic sine of the input.
")]
    [System.Serializable, NodeMenuItem("Function/Math/Sinh")]
    public class SinhNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Output]
        public object output;

        public override string name => "Sinh";
        public override string NodeGroup => "Math";

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (inputA == null)
            {
                output = null;
                return true;
            }

            output = MathF.Sinh(TypeCaster.ToFloat(inputA));
            return true;
        }
    }
}
