using AhahGames.GenesisNoise.Utility;

using GraphProcessor;

using System;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Returns the tangent of the input.
")]

    [System.Serializable, NodeMenuItem("Function/Math/Tan")]
    public class TanNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Output]
        public object output;
        public override string name => "Tan";
        public override string NodeGroup => "Math";
        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (inputA == null)
            {
                output = null;
                return true;
            }
            float val = TypeCaster.ToFloat(inputA);
            output = Mathf.Tan(val);
            return true;
        }
    } 
}

