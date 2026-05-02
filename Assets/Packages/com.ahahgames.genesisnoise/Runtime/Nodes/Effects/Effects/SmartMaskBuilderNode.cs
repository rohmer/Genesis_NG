using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Combines ambient occlusion, cavity, thickness, and slope cues into one reusable smart mask.

This is intended as a flexible mask-building node for:
- Edge wear
- Dirt, moss, and polish placement
- General material authoring workflows
")]
    [System.Serializable, NodeMenuItem("Effects/Smart Mask Builder")]
    public class SmartMaskBuilderNode : SmartMaskEffectNodeBase
    {
        protected override int Mode => 3;

        public override string name => "Smart Mask Builder";
        public override string ShaderName => "Hidden/Genesis/SmartMaskSuite";
    }
}
