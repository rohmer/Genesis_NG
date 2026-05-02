using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
- Sepia toning
- Film fade & contrast loss
- Paper yellowing
- Vignette darkening
- Film grain
- Dust & scratches
- Edge wear
")]

    [System.Serializable, NodeMenuItem("Filters/Artistic/Old Photo")]
    public class OldPhotoNode : FixedNoiseNode
    {
        public override string name => "Old Photo";
        public override string NodeGroup => "Artistic";
        public override string ShaderName => "Hidden/Genesis/OldPhotoFilter";
    }
}
