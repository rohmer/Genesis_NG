using GraphProcessor;

using System.Collections.Generic;
using System.Linq;

using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    public abstract class TerrainMultifractalNodeBase : FixedNoiseNode
    {
        protected abstract int Mode { get; }

        protected override IEnumerable<string> filteredOutProperties => base.filteredOutProperties.Concat(new[] { "_Mode" });

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (material != null)
                material.SetFloat("_Mode", Mode);

            return base.ProcessNode(cmd);
        }
    }

    [Documentation(@"
Hybrid multifractal terrain noise built on a gradient-noise basis.

This is a strong all-purpose terrain foundation when you want:
- Nested broad forms with sharper secondary breakup
- More structure than plain fBm
- A good starting point for erosion and masking workflows
")]
    [System.Serializable, NodeMenuItem("Generators/Noise/Hybrid Multifractal")]
    public class HybridMultifractalNode : TerrainMultifractalNodeBase
    {
        protected override int Mode => 0;

        public override string name => "Hybrid Multifractal";
        public override string ShaderName => "Hidden/Genesis/TerrainFractalSuite";
        public override string NodeGroup => "Noise";
    }

    [Documentation(@"
Hetero terrain multifractal noise with elevation-dependent detail accumulation.

This variant is useful for:
- Terrain where higher regions gather more breakup
- Mountain and mesa style masks
- Height-driven macro-to-micro layering
")]
    [System.Serializable, NodeMenuItem("Generators/Noise/Hetero Terrain")]
    public class HeteroTerrainNode : TerrainMultifractalNodeBase
    {
        protected override int Mode => 1;

        public override string name => "Hetero Terrain";
        public override string ShaderName => "Hidden/Genesis/TerrainFractalSuite";
        public override string NodeGroup => "Noise";
    }

    [Documentation(@"
Ping-pong multifractal noise for stylized, stepped, and aggressively folded terrain breakup.

This mode works well for:
- Stylized cliffs
- Layered erosion masks
- Noisy terraces and folded strata
")]
    [System.Serializable, NodeMenuItem("Generators/Noise/Ping Pong Multifractal")]
    public class PingPongMultifractalNode : TerrainMultifractalNodeBase
    {
        protected override int Mode => 2;

        public override string name => "Ping Pong Multifractal";
        public override string ShaderName => "Hidden/Genesis/TerrainFractalSuite";
        public override string NodeGroup => "Noise";
    }

    [Documentation(@"
Ridged multifractal terrain noise with erosion-friendly cresting.

This node is geared toward:
- Mountain ridges
- Watershed and slope masks
- Feeding later hydraulic, thermal, or wind erosion passes
")]
    [System.Serializable, NodeMenuItem("Generators/Noise/Ridged Multifractal")]
    public class RidgedMultifractalNode : TerrainMultifractalNodeBase
    {
        protected override int Mode => 3;

        public override string name => "Ridged Multifractal";
        public override string ShaderName => "Hidden/Genesis/TerrainFractalSuite";
        public override string NodeGroup => "Noise";
    }
}
