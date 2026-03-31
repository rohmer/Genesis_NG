using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
Simulates Substance’s Curvature node from a height map: convex/concave detection via a Laplacian‑style kernel, remapped to 0–1, with optional separate convex/concave outputs.
")]

    [System.Serializable, NodeMenuItem("Effects/Curvature")]
    public class CurvatureNode : FixedNoiseNode
    {
        public override string name => "Curvature";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/Curvature";
    }
}