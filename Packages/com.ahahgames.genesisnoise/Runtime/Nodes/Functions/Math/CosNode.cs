using AhahGames.GenesisNoise.Utility;

using GraphProcessor;

using System;

using UnityEngine;
using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    [System.Serializable, NodeMenuItem("Function/Math/Cos")]
    public class CosNode : ConstantNode
    {
        [Input(name = "A")]
        public object inputA;

        [Output]
        public object output;
        public override string name => "Cos";
        public override string NodeGroup => "Math";
        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (inputA == null)
            {
                output = null;
                return true;
            }
            float val = TypeCaster.ToFloat(inputA);
            output = Mathf.Cos(val);
            return true;
        }
    }
}
