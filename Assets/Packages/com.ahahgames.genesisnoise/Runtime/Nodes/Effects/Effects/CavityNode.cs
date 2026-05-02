using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Extracts concave cavity information from a height field.

This is useful for:
- Dust and grime buildup masks
- Crack enhancement
- Fine material breakup
")]
    [System.Serializable, NodeMenuItem("Effects/Cavity")]
    public class CavityNode : SmartMaskEffectNodeBase
    {
        protected override int Mode => 1;

        public override string name => "Cavity";
        public override string ShaderName => "Hidden/Genesis/SmartMaskSuite";
    }
}
