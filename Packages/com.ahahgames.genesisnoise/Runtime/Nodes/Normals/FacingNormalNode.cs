using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
 Facing Normal node is one of those deceptively simple utility nodes.   It outputs a grayscale mask based on how much a surface’s normal faces a given view direction (usually the camera or a user‑defined vector).
It's basically:
mask = saturate( dot(normal, viewDir) )
With optional:
- Bias / Contrast
- Invert
- Custom view direction
- Softness shaping
")]

    [System.Serializable, NodeMenuItem("Normal/Facing Normal")]
    public class FacingNormalNode : FixedNoiseNode
    {
        public override string name => "Facing Normal";
        public override string NodeGroup => "Effects";
        public override string ShaderName => "Hidden/Genesis/FacingNormal";
    }
}