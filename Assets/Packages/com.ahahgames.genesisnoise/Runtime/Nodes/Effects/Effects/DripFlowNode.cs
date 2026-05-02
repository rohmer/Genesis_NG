using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Pushes the source texture along a gravity-biased flow field to create streaks and drips.

This node is useful for:
- Vertical grime
- Paint runs
- Water streaking and runoff
")]
    [System.Serializable, NodeMenuItem("Effects/Drip Flow")]
    public class DripFlowNode : FlowEffectNodeBase
    {
        protected override int Mode => 0;

        public override string name => "Drip Flow";
        public override string ShaderName => "Hidden/Genesis/FlowEffectSuite";
    }
}
