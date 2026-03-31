using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 Essentially a real‑time hemispherical light integration node. It computes a soft, view‑independent irradiance term by:
• 	Sampling the source height/albedo
• 	Integrating light from multiple directions
• 	Using a hemisphere kernel
• 	Producing a soft ambient occlusion–like irradiance map
It’s not SSAO, not blur, not curvature — it’s a multi‑directional, weighted gather that simulates diffuse light accumulation.

")]

    [System.Serializable, NodeMenuItem("Effects/Irradiance")]
    public class IrradianceNode : FixedNoiseNode
    {
        public override string name => "Irradiance";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/RTIrradiance";
    }
}