using GraphProcessor;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Raises e to the power of the input.
")]
    [System.Serializable, NodeMenuItem("Function/Math/Exp")]
    public class ExpNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Output]
        public object output;

        public override string name => "Exp";
        public override string NodeGroup => "Math";

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (inputA == null)
            {
                output = null;
                return true;
            }

            output = Mathf.Exp(TypeCaster.ToFloat(inputA));
            return true;
        }
    }
}
