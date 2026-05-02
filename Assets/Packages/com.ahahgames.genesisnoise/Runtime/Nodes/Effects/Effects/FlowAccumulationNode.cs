using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Builds a grayscale flow and pooling mask from the source texture's luminance.

Use this when you want:
- Runoff accumulation masks
- Puddle and stain drivers
- Inputs for later wetness or wear effects
")]
    [System.Serializable, NodeMenuItem("Effects/Flow Accumulation")]
    public class FlowAccumulationNode : FlowEffectNodeBase
    {
        protected override int Mode => 1;

        public override string name => "Flow Accumulation";
        public override string ShaderName => "Hidden/Genesis/FlowEffectSuite";
    }
}
