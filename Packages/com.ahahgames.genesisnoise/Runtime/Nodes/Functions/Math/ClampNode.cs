using AhahGames.GenesisNoise.Utility;

using GraphProcessor;

using System;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
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
            if (min == null)
            {
                output = null;
                return true;
            }
            if (max == null)
            {
                output = null;
                return true;
            }
            if (value == null)
            {
                output = null;
                return true;
            }
            value = Mathf.Clamp(TypeCaster.ToFloat(value), TypeCaster.ToFloat(min), TypeCaster.ToFloat(max));
            return true;
        }
    }
}
