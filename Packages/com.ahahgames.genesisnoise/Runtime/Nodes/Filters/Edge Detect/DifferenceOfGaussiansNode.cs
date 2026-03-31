using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
computes a Difference of Gaussians (DoG) edge response. It performs two small separable Gaussian-like blurs at different radii, subtracts them to produce band-pass edges, applies thresholding and optional softening, and can output an edge mask, overlay edges on the source, or show edges only.
")]

    [System.Serializable, NodeMenuItem("Filters/Edge Detect/Difference of Gaussians")]
    public class DifferenceOfGaussiansNode : FixedShaderNode
    {
        public override string name => "Combine";

        public override string ShaderName => "Hidden/Genesis/DoGEdge";
        public override string NodeGroup => "Operations";
        public override bool DisplayMaterialInspector => true;

    }
}