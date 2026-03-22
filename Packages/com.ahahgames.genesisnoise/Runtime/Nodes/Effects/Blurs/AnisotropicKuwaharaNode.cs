using GraphProcessor;

namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Blur the input texture using a box blur.
")]

    [System.Serializable, NodeMenuItem("Effects/Blur/Anisotropic Kuwahara")]
    public class AnisotropicKuwaharaNode : FixedShaderNode
    {
        public override string name => "Anisotropic Kuwahara";
        public override string NodeGroup => "Blur";
        public override string ShaderName => "Hidden/Genesis/AnisotropicKuwahara";

        public override bool DisplayMaterialInspector => true;
    }
}