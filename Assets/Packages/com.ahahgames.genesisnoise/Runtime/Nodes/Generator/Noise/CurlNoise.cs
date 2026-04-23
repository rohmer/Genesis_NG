using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
The CurlNoise node generates 2D or 3D curl noise derived from Perlin FBM.
Curl noise is divergence‑free, meaning it produces swirling, fluid‑like vector fields with no sinks or sources. This makes it ideal for:
- Flow maps
- Smoke, fire, and fluid motion
- Stylized wind fields
- Particle advection
- Organic distortion fields
- Procedural animation
The node outputs a vector field (XYZ), not scalar noise

")]

    [System.Serializable, NodeMenuItem("Generators/Noise/Curl Noise")]
    public class CurlNoise : FixedNoiseNode
    {
        public override string ShaderName => "Hidden/Genesis/CurlNoise";
        public override string NodeGroup => "Noise";
        public override string name => "Curl Noise";
    }
}