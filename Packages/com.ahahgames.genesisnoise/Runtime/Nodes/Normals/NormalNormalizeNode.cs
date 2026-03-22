using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 Normal Normalize is one of those tiny but essential utility nodes every procedural pipeline needs. It ensures that any incoming normal map (even if modified, blended, warped, or partially invalid) is re‑normalized back into a proper tangent‑space unit vector.
This is especially important after:
- Height‑based blends
- Vector warps
- Curvature modulation
- Manual channel edits
- Procedural normal generation
A proper normalize step prevents shading artifacts and keeps downstream nodes stable.

")]

    [System.Serializable, NodeMenuItem("Normal/Normal Normalize")]
    public class NormalNormalizeNode : FixedNoiseNode
    {
        public override string name => "Normal Normalize";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/NormalNormalize";
    }
}