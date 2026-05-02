using GraphProcessor;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Returns the arctangent of A / B while preserving the quadrant.
")]
    [System.Serializable, NodeMenuItem("Function/Math/Atan2")]
    public class Atan2Node : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Input(name = "B")]
        public object inputB;

        [Output]
        public object output;

        public override string name => "Atan2";
        public override string NodeGroup => "Math";

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (inputA == null || inputB == null)
            {
                output = null;
                return true;
            }

            output = Mathf.Atan2(TypeCaster.ToFloat(inputA), TypeCaster.ToFloat(inputB));
            return true;
        }
    }
}
