using GraphProcessor;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Returns the arccosine of the input.
")]
    [System.Serializable, NodeMenuItem("Function/Math/Acos")]
    public class AcosNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Output]
        public object output;

        public override string name => "Acos";
        public override string NodeGroup => "Math";

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (inputA == null)
            {
                output = null;
                return true;
            }

            output = Mathf.Acos(TypeCaster.ToFloat(inputA));
            return true;
        }
    }
}
