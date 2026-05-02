using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Builds a broad ambient-occlusion style mask from the incoming height field.

Use this when you want:
- Large-scale dirt and shadow masks
- Soft contact darkening
- A reusable base for wear and deposition
")]
    [System.Serializable, NodeMenuItem("Effects/Ambient Occlusion")]
    public class AmbientOcclusionNode : SmartMaskEffectNodeBase
    {
        protected override int Mode => 0;

        public override string name => "Ambient Occlusion";
        public override string ShaderName => "Hidden/Genesis/SmartMaskSuite";
    }
}
