using GraphProcessor;

using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Clamps the input to a specified range.
")]
    [System.Serializable, NodeMenuItem("Function/Math/Clamp")]
    public class ClampNode : ConstantNode
    {
        [Input(name = "Min")]
        public object min;

        [Input(name = "Max")]
        public object max;

        [Input(name = "Value")]
        public object value;

        [Output]
        public object output;

        public override string name => "Clamp";
        public override string NodeGroup => "Math";

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            output = MathOperationUtility.ClampValue(value, min, max);
            return true;
        }
    }
}
