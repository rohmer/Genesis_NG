using GraphProcessor;
namespace AhahGames.GenesisNoise.Nodes
{
    [Documentation(@"
Generates a houndstooth pattern
")]

    [System.Serializable, NodeMenuItem("Generators/Shapes/Houndstooth")]
    public class HoundstoothNode : FixedShaderNode
    {
        public override string name => "Houndstooth";

        public override string ShaderName => "Hidden/Genesis/Houndstooth";

        public override bool DisplayMaterialInspector => true;

    }
}