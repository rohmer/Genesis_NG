using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

namespace AhahGames.GenesisNoise.Ndes
{
    [Documentation(@"
Sample a texture. Note that you can use a custom UV texture as well.
")]

    [System.Serializable, NodeMenuItem("Operations/Textures/Texture Sampler")]
    public class TextureSamplerNode : FixedShaderNode
    {
        public override string name => "Texture Sampler";

        public override string ShaderName => "Hidden/Genesis/TextureSample";

        public override bool DisplayMaterialInspector => true;
    }
}