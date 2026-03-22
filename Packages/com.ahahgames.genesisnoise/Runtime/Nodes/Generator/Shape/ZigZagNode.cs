using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a Zig-Zag pattern
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Zig Zag")]
    public class ZigZagNode : FixedShaderNode
    {
        public override string name => "Zig Zag";

        public override string ShaderName => "Hidden/Genesis/ZigZag";

        public override bool DisplayMaterialInspector => true;
        public override string NodeGroup => "Shape";
    }
}