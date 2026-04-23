using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a smooth wave pattern
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Smooth Wave")]
    public class SmoothWaveNode : FixedShaderNode
    {
        public override string name => "Smooth Wave";

        public override string ShaderName => "Hidden/Genesis/SmoothWave";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}