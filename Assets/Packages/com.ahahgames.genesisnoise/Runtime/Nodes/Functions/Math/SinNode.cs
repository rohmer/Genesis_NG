using AhahGames.GenesisNoise.Utility;

using GraphProcessor;

using System;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Returns the sine of the input.
")]

    [System.Serializable, NodeMenuItem("Function/Math/Sin")]
    public class SinNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Output]
        public object output;
        public override string name => "Sin";
        public override string NodeGroup => "Math";
        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (inputA == null)
            {
                output = null;
                return true;
            }
            float val = TypeCaster.ToFloat(inputA);
            output = Mathf.Sin(val);
            return true;
        }
    }
}
 
