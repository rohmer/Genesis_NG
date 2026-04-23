using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 Non‑Uniform Rotation is a killer addition to your coordinate‑space toolkit — it’s the rotational equivalent of Non‑Square Transform. Instead of scaling X and Y independently, we rotate UVs with different rotation angles per axis, producing:
✔ Anisotropic rotation
✔ Direction‑dependent twisting
✔ Elliptical swirl effects
✔ Pre‑warping for polar, kaleidoscope, and flow nodes
✔ Perfect for procedural shapes, noise, and patterns
")]

    [System.Serializable, NodeMenuItem("Transform/Non-Uniform Rotation")]
    public class NonUniformRotationNode : FixedNoiseNode
    {
        public override string name => "Non-Uniform Rotation";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/NonUniformRotation";
    }
}