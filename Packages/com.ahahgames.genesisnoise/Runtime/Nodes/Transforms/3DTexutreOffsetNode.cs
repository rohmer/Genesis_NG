using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{

    [Documentation(@"
3D Texture Offset Color is a perfect utility node for volumetric workflows — it lets you shift a 3D texture in XYZ space and sample it at an offset
")]

    [System.Serializable, NodeMenuItem("Transform/3D Texture Offset")]
    public class TextureOffsetNode3D : FixedNoiseNode
    {
        public override string name => "3D Texture Offset Node";
        public override string NodeGroup => "Transforms";
        public override string ShaderName => "Hidden/Genesis/TextureOffset3D";
    }
}