using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Approximates local thickness and sheltered interior regions from a height field.

This node works well for:
- Moss and wetness placement
- Interior wear masks
- Protected-region selection
")]
    [System.Serializable, NodeMenuItem("Effects/Thickness")]
    public class ThicknessNode : SmartMaskEffectNodeBase
    {
        protected override int Mode => 2;

        public override string name => "Thickness";
        public override string ShaderName => "Hidden/Genesis/SmartMaskSuite";
    }
}
