using AhahGames.GenesisNoise.Nodes;

using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Sample a texture. Note that you can use a custom UV texture as well.
")]
    [UnityEngine.Scripting.APIUpdating.MovedFrom(false, sourceNamespace: "AhahGames.GenesisNoise.Ndes", sourceAssembly: "Genesis Noise", sourceClassName: "TextureSamplerNode")]
    [System.Serializable, NodeMenuItem("Operations/Textures/Texture Sampler")]
    public class TextureSamplerNode : FixedShaderNode
    {
        public override string name => "Texture Sampler";

        public override string ShaderName => "Hidden/Genesis/TextureSample";

        public override bool DisplayMaterialInspector => true;
    }
}
