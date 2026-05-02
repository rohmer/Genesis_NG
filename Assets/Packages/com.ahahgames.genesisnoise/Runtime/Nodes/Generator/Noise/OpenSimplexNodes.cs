using GraphProcessor;

using System.Collections.Generic;
using System.Linq;

using UnityEngine.Rendering;

namespace AhahGames.GenesisNoise.Nodes
{
    public abstract class OpenSimplexNodeBase : FixedNoiseNode
    {
        protected abstract int Variant { get; }

        protected override IEnumerable<string> filteredOutProperties => base.filteredOutProperties.Concat(new[] { "_Variant" });

        protected override bool ProcessNode(CommandBuffer cmd)
        {
            if (material != null)
                material.SetFloat("_Variant", Variant);

            return base.ProcessNode(cmd);
        }
    }

    [Documentation(@"
Generates OpenSimplex2 noise using the package's ImproveXY-style lattice mapping.

This node supports:
- 2D slice and 3D evaluation
- Multi-octave layering
- Derivative-vector output for flow fields and slope masks
- Greyscale noise output for terrain, clouds, breakup, and distortion
")]
    [System.Serializable, NodeMenuItem("Generators/Noise/OpenSimplex2")]
    public class OpenSimplex2Node : OpenSimplexNodeBase
    {
        protected override int Variant => 0;

        public override string name => "OpenSimplex2";
        public override string ShaderName => "Hidden/Genesis/OpenSimplexSuite";
        public override string NodeGroup => "Noise";
    }

    [Documentation(@"
Generates OpenSimplex2S noise using the package's smooth ImproveXY derivative variant.

This node is useful when you want:
- Softer lattice transitions than OpenSimplex2
- Directional derivative output for vector fields
- Organic terrain breakup and volumetric masking
")]
    [System.Serializable, NodeMenuItem("Generators/Noise/OpenSimplex2S")]
    public class OpenSimplex2SNode : OpenSimplexNodeBase
    {
        protected override int Variant => 1;

        public override string name => "OpenSimplex2S";
        public override string ShaderName => "Hidden/Genesis/OpenSimplexSuite";
        public override string NodeGroup => "Noise";
    }
}
