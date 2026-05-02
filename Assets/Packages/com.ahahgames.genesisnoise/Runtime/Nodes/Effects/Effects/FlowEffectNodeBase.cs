using System.Collections.Generic;
using System.Linq;

using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    public abstract class FlowEffectNodeBase : FixedNoiseNode
    {
        protected abstract int Mode { get; }

        public override string NodeGroup => "Effects";

        protected override IEnumerable<string> filteredOutProperties => base.filteredOutProperties.Concat(new[] { "_Mode" });

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (material != null)
                material.SetFloat("_Mode", Mode);

            return base.ProcessNode(cmd);
        }
    }
}
