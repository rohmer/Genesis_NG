using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Darkens and softens the source using a derived flow and pooling mask to suggest wet material.

This is a good fit for:
- Puddled surfaces
- Damp streaks
- Rain-darkened materials
")]
    [System.Serializable, NodeMenuItem("Effects/Wetness")]
    public class WetnessNode : FlowEffectNodeBase
    {
        protected override int Mode => 2;

        public override string name => "Wetness";
        public override string ShaderName => "Hidden/Genesis/FlowEffectSuite";
    }
}
